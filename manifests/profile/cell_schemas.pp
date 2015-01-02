class i2b2::profile::cell_schemas(
  $ontology_db_user  = 'i2b2metadata',
  $ontology_db_password = 'i2b2metadata',
) {
  include i2b2::cell_schemas::pm
  include i2b2::cell_schemas::hive

  i2b2::cell_schemas::ontology { 'i2b2metadata':
    db_user     => $ontology_db_user,
    db_password => $ontology_db_password,
  }
}
