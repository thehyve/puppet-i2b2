require 'pg'

Puppet::Type.type(:table_row).provide(:pg_table_row_provider) do

  def initialize(*args)
    super(*args)
    # guard to avoid trying to change the user twice
    @changed_user = false
  end

  # ensure property

  def create
    columns = resource[:identity].keys + resource[:values].keys
    params = resource[:identity].values + resource[:values].values
    placeholders = (['?'] * columns.size).join ', '
    sql = "INSERT INTO #{table}(#{columns.join ', '}) VALUES(#{placeholders})"
    result = issue_query sql, params

    validate_update_result sql, where_params, result
  end

  def destroy
    sql = "DELETE FROM #{table} #{where_clause}"
    result = issue_query sql, where_params
    validate_update_result sql, where_params, result
  end

  def exists?
    # instead of issuing a separate query with EXISTS or COUNT(*), take this
    # opportunity to cache the values property. This saves puppet from querying
    # the state of the 'values' by issuing another query.
    values != :absent
  end


  # other properties

  def values
    return @property_hash[:values] if @property_hash.has_key? :values

    @property_hash[:values] = begin
      sql = "SELECT #{value_columns} FROM #{table} #{where_clause}"
      result = issue_query sql, where_params

      if result.ntuples == 0
        :absent
      elsif result.ntuples == 1
        resource.parameter(:values).munge result[0]
      else
        fail_multiple_rows result.ntuples
      end
    end
  end

  def values=(new_hash)
    unless new_hash == resource[:values]
      raise Puppet::DevError, 'Expected property setter argument to be equal ' \
                              "to the 'should' value of the property"
    end

    sql = "UPDATE #{table} SET #{update_fragment} #{where_clause}"
    params = value_values + where_params
    result = issue_query sql, params

    validate_update_result sql, params, result
  end


  # auxiliary methods

  def table
    resource[:table]
  end

  def with_connection(&block)
    params = resource[:connect_params]
    Puppet.debug "Connecting to PostgreSQL database with parameters #{params}"
    with_chosen_user do
      conn = PG.connect params
      begin
        conn.transaction { |c| block[c] }
      ensure
        conn.finish
      end
    end
  end

  def issue_query(sql, params)
    i = 0
    transformed_sql = sql.gsub(/\?/) { "$#{i += 1}" }
    with_connection do |conn|
      Puppet.notice "Issuing query #{transformed_sql} with parameters #{params}"
      conn.exec_params transformed_sql, params
    end
  end

  def where_clause
    "WHERE " +
        resource[:identity].map do |(k)|
          "#{k} = ?"
        end.join(' AND ')
  end

  def where_params
    resource[:identity].values
  end

  def value_columns
    resource[:values].keys.join ', '
  end

  def value_values # yep, great naming
    resource[:values].values
  end

  def update_fragment
    resource[:values].keys.map { |k| "#{k} = ?"}.join ', '
  end

  def validate_update_result(sql, params, pgresult)
    num_tuples = pgresult.cmd_tuples
    if num_tuples != 1
      fail "Expected the statement #{sql} with parameters #{params} to " \
           "affect exactly 1 row; it affected #{num_tuples} instead"
    end
  end

  def fail_multiple_rows num_rows
    fail "Found more than 1 row (#{num_rows}) in table '#{table}' and identity #{resource[:identity]}"
  end

  def with_chosen_user
    user = resource[:system_user]
    if @changed_user or user.nil?
      yield
      return
    end

    begin
      @changed_user = true
      Puppet::Util::SUIDManager.asuser(user) { yield }
    ensure
      @changed_user = false
    end
  end

end
