# can be used in an arbitrary server with access to the database
class i2b2::profile::database_data(
  $ontology_db_user  = 'i2b2metadata',
  $ontology_db_password = 'i2b2metadata',
  $default_project = true,
) {
  include i2b2::cell_schemas::pm
  include i2b2::cell_schemas::hive
  include i2b2::cell_schemas::hive_data
  include i2b2::cell_data::default_admin
  include i2b2::cell_data::service_user

  i2b2::cell_schemas::ontology { 'i2b2metadata':
    db_user     => $ontology_db_user,
    db_password => $ontology_db_password,
  }

  if $default_project {
    i2b2::project { 'default':
      project_name => 'Default',
      domain       => $params::hive_domain_name,
      cell_schemas => {
        'ontology'   => $ontology_db_user,
      }
    }

    i2b2_user_roles { "{$params::service_user}:default":
      roles => [
        'USER',
        'MANAGER',
        'DATA_OBFSC',
        'DATA_AGG',
      ]
    }
  }
}
