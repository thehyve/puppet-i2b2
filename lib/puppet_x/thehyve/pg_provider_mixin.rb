require 'pg'

module PuppetX
module Thehyve
module PgProviderMixin

  def initialize(*args)
    super(*args)
    # guard to avoid trying to change the user twice
    @changed_user = false
  end

  def issue_query(sql, params)
    i = 0
    transformed_sql = sql.gsub(/\?/) { "$#{i += 1}" }
    with_connection do |conn|
      Puppet.notice "Issuing query #{transformed_sql} with parameters #{params}"
      conn.exec_params transformed_sql, params
    end
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


  private

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

end
end
end
