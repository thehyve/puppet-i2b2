define i2b2::cell_schemas::im(
  $db_user,
  $db_password,
  $demo_data = false
) {
  common { "im-$name":
    ant_script_dir     => 'Imdata',
    database_user      => $db_user,
    database_password  => $db_password,
    target_infix       => 'imdata',
    additional_targets => $demo_data ? {
      true    => ['db_imdata_load_data'],
      default => [],
    }
  }
}
