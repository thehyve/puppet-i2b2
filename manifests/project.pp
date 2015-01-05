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
    identity => { 'project_id' => $name },
    values   => {
      project_name => $project_name,
      project_wiki => $wiki,
      project_path => "/$name",
      status_cd    => 'A',
    }
  }

  $spec = i2b2_project_massage_lookup($name, $params::hive_domain_name /* not id! */,
    $params::hive_db_user, $params::database_type, $cell_schemas)

  create_resources('table_row', $spec, { ensure => $ensure })
}
