class i2b2::cell_schemas::pm(
  $db_user     = $::i2b2::params::pm_db_user,
  $db_password = $::i2b2::params::pm_db_password,
) inherits i2b2::params {

  # there can only be one pm cell database

  i2b2::cell_schemas::common { 'pm':
    ant_script_dir     => 'Pmdata',
    database_user      => $db_user,
    database_password  => $db_password,
    target_infix       => 'pmdata',
    additional_targets => ["create_triggers_release_$::i2b2::params::ant_target_version"],
  }
}
