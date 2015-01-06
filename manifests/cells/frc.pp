class i2b2::cells::frc inherits i2b2::params {
  require i2b2::i2b2src_files
  require i2b2::cells::hive

  $src_dir = "$i2b2::i2b2src_files::dir/edu.harvard.i2b2.fr"

  modified_properties_file { "$src_dir/etc/spring/edu.harvard.i2b2.fr.properties":
    values => {
      'edu.harvard.i2b2.fr.ws.pm.url' => "$params::local_url/services/PMService/getServices",
    },
    notify => I2b2::Cells::Common['frc']
  }

  i2b2::cells::common { 'frc':
    cell_source_dir   => $src_dir,
    user              => $params::user,
    file_to_check     => 'FR-core.jar',
    pm_cell_user      => $params::pm_db_user,
    app_dir_prop_file => "$src_dir/etc/spring/fr_application_directory.properties",
    app_dir_key       => 'edu.harvard.i2b2.fr.applicationdir',
    cell_id           => 'FRC',
    cell_details      => {
      name   => 'File Repository',
      url    => "$params::external_url/services/FRService/",
      method => SOAP,
    }
  }

}
