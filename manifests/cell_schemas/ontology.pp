define i2b2::cell_schemas::ontology(
  $db_user,
  $db_password,
  $demo_data = false,
) {

  common { "ontology-$name":
    ant_script_dir     => 'Metadata',
    database_user      => $db_user,
    database_password  => $db_password,
    datasource_name    => "${name}DS",
    target_infix       => 'metadata',
    additional_targets => $demo_data ? {
      true    => 'db_metadata_load_data',
      default => [],
    }
  }
}
