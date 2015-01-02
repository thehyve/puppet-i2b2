class i2b2::cell_schemas::hive(
  $db_user     = $params::hive_db_user,
  $db_password = $params::hive_db_password,
) inherits i2b2::params {

  # there can only be one hive cell database

  i2b2::cell_schemas::common { 'hive':
    ant_script_dir     => 'Hivedata',
    database_user      => $db_user,
    database_password  => $db_password,
    target_infix       => 'hivedata',
    additional_targets => [],
  }
}
