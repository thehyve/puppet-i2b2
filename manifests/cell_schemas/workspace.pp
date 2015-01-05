define i2b2::cell_schemas::workspace(
  $db_user,
  $db_password,
  $demo_data = false
) {
  common { "workspace-$name":
    ant_script_dir     => 'Workdata',
    database_user      => $db_user,
    database_password  => $db_password,
    target_infix       => 'workdata',
    additional_targets => $demo_data ? {
      true    => ['db_workdata_load_data'],
      default => [],
    }
  }
}
