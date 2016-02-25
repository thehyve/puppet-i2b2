define i2b2::cell_schemas::workspace(
  $db_user,
  $db_password,
  $demo_data = false,
) {
  $additional_targets = $demo_data ? {
    true    => ['db_workdata_load_data'],
    default => [],
  }

  i2b2::cell_schemas::common { "workspace-$name":
    ant_script_dir     => 'Workdata',
    database_user      => $db_user,
    database_password  => $db_password,
    target_infix       => 'workdata',
    additional_targets => $additional_targets,
  }
  ->
  # default private workspace
  table_row { "default-private-workplace-$name":
    table    => "$db_user.workplace_access",
    identity => {
      c_index => 0
    },
    values   => {
      c_table_cd         => 'default',
      c_table_name       => 'WORKPLACE',
      c_protected_access => 'N',
      c_hlevel           => 0,
      c_name             => '@',
      c_user_id          => '@',
      c_group_id         => '@',
      c_share_id         => 'N',
      c_visualattributes => 'CA ', # final space is important
      c_tooltip          => '@',
    }
  }
}
