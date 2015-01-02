require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'thehyve', 'pg_provider_mixin.rb'))

Puppet::Type.type(:i2b2_user_roles).provide(:pg_i2b2_user_roles) do
  include PuppetX::Thehyve::PgProviderMixin

  # auxiliary methods

  def roles
    return @property_hash[:roles] if @property_hash.has_key? :roles

    @property_hash[:roles] = begin
      sql = "SELECT user_role_cd FROM #{table} #{where_clause}"
      result = issue_query sql, where_params

      result.values.map { |(a)| a }
    end
  end

  def roles=(should_roles)
    new_roles = should_roles - roles
    removed_roles = roles - should_roles

    unless new_roles.empty?
      insert_sql = "INSERT INTO #{table}(project_id, user_id, user_role_cd, status_cd) " \
          "VALUES #{new_roles.map { '(?, ?, ?, ?)' }.join(', ')}"
      insert_values = new_roles.map do |role|
        [
            resource[:project],
            resource[:username],
            role,
            'A'
        ]
      end.flatten

      issue_query insert_sql, insert_values
    end

    unless removed_roles.empty?
      delete_sql = "DELETE FROM #{table} #{where_clause} " \
          "AND user_role_cd IN (#{removed_roles.map { '?' }.join(', ')})"
      delete_values = where_params + removed_roles

      issue_query delete_sql, delete_values
    end
  end

  private

  def table
    resource.table
  end

  def where_clause
    'WHERE project_id = ? AND user_id = ?'
  end

  def where_params
    [resource[:project], resource[:username]]
  end
end
