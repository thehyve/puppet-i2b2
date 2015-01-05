require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'thehyve', 'pg_provider_mixin.rb'))

Puppet::Type.type(:table_row).provide(:pg_table_row_provider) do
  include PuppetX::Thehyve::PgProviderMixin

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

end
