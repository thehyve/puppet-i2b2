class i2b2::cells::im inherits i2b2::params {
  require i2b2::i2b2src_files
  require i2b2::cells::hive

  $src_dir = "$i2b2::i2b2src_files::dir/edu.harvard.i2b2.im"

  modified_properties_file { "$src_dir/etc/spring/im.properties":
    values => {
      'im.bootstrapdb.imschema' => $params::hive_db_user,
      'im.ws.pm.url'            => "$params::local_url/services/PMService/getServices",
    },
  }
  ~>
  i2b2::cells::common { 'im':
    cell_source_dir    => $src_dir,
    user               => $params::user,
    file_to_check      => 'IM-core.jar',
    pm_cell_user       => $params::pm_db_user,
    bootstrap_prefix   => 'IM',
    bootstrap_user     => $params::hive_db_user,
    bootstrap_password => $params::hive_db_password,
    app_dir_prop_file  => "$src_dir/etc/spring/im_application_directory.properties",
    app_dir_key        => 'edu.harvard.i2b2.im.applicationdir',
    cell_id            => 'IM',
    cell_details       => {
      name   => 'IM Cell',
      url    => "$params::external_url/services/IMService/",
      method => REST,
    }
  }

}
