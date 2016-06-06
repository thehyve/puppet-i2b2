class i2b2::cells::ontology inherits i2b2::params {
  require i2b2::i2b2src_files
  require i2b2::cells::hive

  $src_dir = "$i2b2::i2b2src_files::dir/edu.harvard.i2b2.ontology"

  modified_properties_file { "$src_dir/etc/spring/ontology.properties":
    values => {
      'ontology.bootstrapdb.metadataschema'                  => $::i2b2::params::hive_db_user,
      'ontology.ws.pm.url'                                   => "$::i2b2::params::local_url/services/PMService/getServices",
      'edu.harvard.i2b2.ontology.ws.fr.url'                  => "$::i2b2::params::local_url/services/FRService",
      'edu.harvard.i2b2.ontology.ws.crc.url'                 => "$::i2b2::params::local_url/services/QueryToolService",
      'edu.harvard.i2b2.ontology.pm.serviceaccount.user'     => $::i2b2::params::service_user,
      'edu.harvard.i2b2.ontology.pm.serviceaccount.password' => $::i2b2::params::service_user_password,
    },
    notify => I2b2::Cells::Common['ontology']
  }

  i2b2::cells::common { 'ontology':
    cell_source_dir    => $src_dir,
    user               => $::i2b2::params::user,
    file_to_check      => 'Ontology-core.jar',
    pm_cell_user       => $::i2b2::params::pm_db_user,
    bootstrap_prefix   => 'Ontology',
    bootstrap_user     => $::i2b2::params::hive_db_user,
    bootstrap_password => $::i2b2::params::hive_db_password,
    app_dir_prop_file  => "$src_dir/etc/spring/ontology_application_directory.properties",
    app_dir_key        => 'edu.harvard.i2b2.ontology.applicationdir',
    cell_id            => 'ONT',
    cell_details       => {
      name   => 'Ontology Cell',
      url    => "$::i2b2::params::external_url/services/OntologyService/",
      method => 'REST',
    }
  }

}
