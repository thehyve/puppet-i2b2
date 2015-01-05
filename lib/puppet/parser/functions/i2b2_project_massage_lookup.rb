module Puppet::Parser::Functions
  I2B2_LOOKUP_TABLES = {
      'ontology'  => 'ont_db_lookup',
      'im'        => 'im_db_lookup',
      'crc'       => 'crc_db_lookup',
      'workspace' => 'work_db_lookup',
  }

  newfunction(:i2b2_project_massage_lookup, :type => :rvalue, :doc => <<-'EOS'
    Transforms the project cell database associations in the form
    { ontology => i2b2metadata, ... } into something that can be passed to
    create_resources to create table_row resources.
  EOS
  ) do |arguments|

    raise(Puppet::ParseError, "i2b2_project_massage_loookup(): Wrong number " \
        "of arguments given (#{arguments.size} for 5)") if arguments.size != 5

    (project, domain, hive_user, db_type, associations) = arguments

    entries = associations.map do |(cell, schema)|
      lookup_table = I2B2_LOOKUP_TABLES[cell]

      raise(Puppet::ParseError, "i2b2_project_massage_loookup(): bad cell " \
          "#{cell} ") if lookup_table.nil?

      [
          "lookup-#{project}-#{cell}",
          {
              :table => "#{hive_user}.#{lookup_table}",
              :identity => {
                  :c_domain_id    => domain,
                  :c_project_path => "#{project}/",
                  :c_owner_id     => '@',
              },
              :values => {
                  :c_db_fullschema => schema,
                  :c_db_datasource => "java:/#{schema}",
                  :c_db_servertype => db_type.upcase,
                  :c_db_nicename   => cell,
              }

          }
      ]
    end

    Hash[entries]
  end
end
