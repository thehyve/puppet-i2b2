class i2b2::cells::crc inherits i2b2::params {
  require i2b2::i2b2src_files
  require i2b2::cells::hive

  $src_dir = "$i2b2::i2b2src_files::dir/edu.harvard.i2b2.crc"

  $dbtype = $params::database_type
  $dbtype_upcase = inline_template('<%= @dbtype.upcase %>')

  modified_properties_file { "$src_dir/etc/spring/edu.harvard.i2b2.crc.loader.properties":
    values => {
      'edu.harvard.i2b2.crc.loader.ws.fr.url'            => "$params::local_url/services/FRService/",
      'edu.harvard.i2b2.crc.loader.ws.pm.url'            => "$params::local_url/services/PMService/getServices",
      'edu.harvard.i2b2.crc.loader.ds.lookup.servertype' => $dbtype_upcase,

    }
  } ~> I2b2::Cells::Common['crc']

  modified_properties_file { "$src_dir/etc/spring/crc.properties":
    values => {
      'queryprocessor.ws.pm.url'                        => "$params::local_url/services/PMService/getServices",
      'queryprocessor.ds.lookup.servertype'             => $dbtype_upcase,
      'queryprocessor.ws.ontology.url'                  => "$params::local_url/services/OntologyService/getTermInfo",
      'edu.harvard.i2b2.crc.delegate.ontology.url'      => "$params::local_url/services/OntologyService",
      'edu.harvard.i2b2.crc.pm.serviceaccount.user'     => $params::service_user,
      'edu.harvard.i2b2.crc.pm.serviceaccount.password' => $params::service_user_password,
    },
  } ~> I2b2::Cells::Common['crc']

  i2b2::cells::common { 'crc':
    cell_source_dir    => $src_dir,
    user               => $params::user,
    file_to_check      => 'CRC-core.jar',
    pm_cell_user       => $params::pm_db_user,
    bootstrap_prefix   => 'CRC',
    bootstrap_user     => $params::hive_db_user,
    bootstrap_password => $params::hive_db_password,
    ant_build_xml      => 'master_build.xml',

    app_dir_prop_file  => "$src_dir/etc/spring/crc_application_directory.properties",
    app_dir_key        => 'edu.harvard.i2b2.crc.applicationdir',
    cell_id            => 'CRC',
    cell_details       => {
      name   => 'Data Repository',
      url    => "$params::external_url/services/QueryToolService/",
      method => REST,
    }
  }
}
