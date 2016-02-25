define i2b2::cell_schemas::crc(
  $db_user,
  $db_password,
  $demo_data = false
) {
  i2b2::cell_schemas::common { "crc-$name":
    ant_script_dir     => 'Crcdata',
    database_user      => $db_user,
    database_password  => $db_password,
    target_infix       => 'crcdata',
    additional_targets => [
      "create_procedures_release_$::i2b2::params::ant_target_version",
      $demo_data ? {
          true    => 'db_demodata_load_data',
          default => [],
      }
    ]
  }
}
