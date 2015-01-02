require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'thehyve', 'i2b2_param_mixin.rb'))

Puppet::Type.newtype(:table_row) do
  extend PuppetX::Thehyve::I2b2ParamMixin

  ensurable

  @doc = <<-'EOT'
      Represents a database table row. The identity of the row is defined by
      the `identity` parameter and the value of the remaining rows by the
      `values` parameter.
  EOT

  newparam :name do
    desc 'The name parameter for this type, filled verbatim from the title. ' \
         'Arbitrary'
  end

  new_string_valued_hash_param :connect_params do
    isrequired

    desc <<-'EOT'
      The connection parameters for the database. For details, see
      [the libpq documentation](http://www.postgresql.org/docs/9.4/static/libpq-connect.html#LIBPQ-CONNSTRING).
      Given in hash form.
    EOT

    def value
      super().inject('') do |s, (k, v)|
        s + "#{k}='" + v.to_s.gsub(/['\\]/, '\\\\\0') + "' "
      end
    end
  end

  newparam :table do
    isrequired

    desc 'The database table to use.'
  end

  new_string_valued_hash_param :identity do
    isrequired

    desc <<-'EOT'
      A hash whose pairs represent column names mapping to row values. The row
      to modify (if it already exists), will be located by using a where clause
      `<key1> = '<value1>' AND <key2> = '<value2>'`. When inserting a new row,
      the values provided here will be inserted alongside those given for the
      `values` property.
    EOT

    validate do |value|
      fail "cannot be empty" if value.empty?
    end
  end

  new_string_valued_hash_param(:values, :create_property => true) do
    isrequired

    default

    desc 'A hash representing the values of the non-identity columns.'
  end

  newparam :system_user do
    desc 'If setting the uid is required, the system user to change to.'
  end

end
