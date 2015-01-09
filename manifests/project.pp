define i2b2::project(
  # $name is project id
  $project_name,
  $domain,
  $cell_schemas, # { ontology => i2b2metadata, ... }
  $wiki = 'http://www.i2b2.org',
  $ensure = present,
) {
  include i2b2::params

  require i2b2::cell_schemas::hive

  # cell overrides (e.g. using remote cells) is not supported
  # would require insertion in pm_cell_data

  # make sure the schemas referenced in $cell_schemas actually exist
  I2b2::Database_user[values($cell_schemas)]
  ->
  I2b2::Project[$title]


  table_row { "project $name project_data":
    ensure   => $ensure,
    table    => "$params::pm_db_user.pm_project_data",
    identity => {
      'project_id' => $name
    },
    values   => {
      project_name => $project_name,
      project_wiki => $wiki,
      project_path => "/$name",
      status_cd    => 'A',
    }
  }

  # Note that the role attribution with project = @ for i2b2 (admin)
  # is NOT enough to allow that user to login (project is not listed
  # for the user in the get_user_configuration PM service call

  $service_user_roles = $ensure ? {
    'present' => [
      'USER',
      'MANAGER',
      'DATA_OBFSC',
      'DATA_AGG',
    ],
    default  => [],
  }

  i2b2_user_roles { "${params::service_user}:$name":
    skip_project_dep => true,
    roles            => $service_user_roles,
  }

  $admin_user_roles = $ensure ? {
    'present' => [
      'USER',
      'MANAGER',
      'DATA_OBFSC',
      'DATA_AGG',
      'DATA_PROT',
      'DATA_LDS',
    ],
    default  => [],
  }

  i2b2_user_roles { "i2b2:$name":
    skip_project_dep => true,
    roles            => $admin_user_roles,
  }

  $spec = i2b2_project_massage_lookup($name, $params::hive_domain_name, # not id!
    $params::hive_db_user, $params::database_type, $cell_schemas)

  create_resources('table_row', $spec, { ensure => $ensure })
}
