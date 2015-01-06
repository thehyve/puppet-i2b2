# can be used in an arbitrary server with access to the database
class i2b2::profile::database_data(
  $ontology_db_user  = 'i2b2metadata',
  $ontology_db_password = 'i2b2metadata',
  $crc_db_user = 'i2b2crc',
  $crc_db_password = 'i2b2crc',
  $work_db_user = 'i2b2work',
  $work_db_password = 'i2b2work',
  $im_db_user = 'i2b2im',
  $im_db_password = 'i2b2im',
  $default_project = true,
  $demo_data = true,
) {
  include i2b2::cell_schemas::pm
  include i2b2::cell_schemas::hive

  include i2b2::cell_data::hive_data
  include i2b2::cell_data::default_admin
  include i2b2::cell_data::service_user

  i2b2::cell_schemas::ontology { 'i2b2metadata':
    db_user     => $ontology_db_user,
    db_password => $ontology_db_password,
    demo_data   => $demo_data,
  }

  i2b2::cell_schemas::crc { 'i2b2crc':
    db_user     => $crc_db_user,
    db_password => $crc_db_password,
    demo_data   => $demo_data,
  }

  i2b2::cell_schemas::workspace { 'i2b2work':
    db_user     => $work_db_user,
    db_password => $work_db_password,
    demo_data   => $demo_data,
  }

  i2b2::cell_schemas::im { 'i2b2im':
    db_user     => $im_db_user,
    db_password => $im_db_password,
    demo_data   => $demo_data,
  }

  if $default_project {
    i2b2::project { 'default':
      project_name => 'Default',
      domain       => $params::hive_domain_name,
      cell_schemas => {
        'ontology'  => $ontology_db_user,
        'crc'       => $crc_db_user,
        'workspace' => $work_db_user,
        'im'        => $im_db_user,
      }
    }
  }
}
