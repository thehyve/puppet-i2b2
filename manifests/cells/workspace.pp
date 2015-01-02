class i2b2::cells::workspace inherits i2b2::params {
  require i2b2::i2b2src_files
  require i2b2::cells::hive

  $src_dir = "$i2b2::i2b2src_files::dir/edu.harvard.i2b2.workplace"

  modified_properties_file { "$src_dir/etc/spring/workplace.properties":
    values => {
      'workplace.bootstrapdb.metadataschema' => $params::hive_db_user,
      'workplace.ws.pm.url'                  => "$params::local_url/services/PMService/getServices",
    },
  }
  ~>
  i2b2::cells::common { 'workspace':
    cell_source_dir    => $src_dir,
    user               => $params::user,
    file_to_check      => 'Workplace-core.jar',
    pm_cell_user       => $params::pm_db_user,
    bootstrap_prefix   => 'Workplace',
    bootstrap_user     => $params::hive_db_user,
    bootstrap_password => $params::hive_db_password,
    app_dir_prop_file  => "$src_dir/etc/spring/workplace_application_directory.properties",
    app_dir_key        => 'edu.harvard.i2b2.workplace.applicationdir',
    cell_id            => 'WORK',
    cell_details       => {
      name   => 'Workplace Cell',
      url    => "$params::external_url/services/WorkplaceService/",
      method => REST,
    }
  }

}
