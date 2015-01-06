define i2b2::profile::postgresql::no_cell_data_detect(
  # $name is the schema name
  $database_user,
  $database_password,
) {
  include i2b2::params

  $dbname = $::i2b2::params::database_name

  postgresql_psql { "detect table non-existence on schema $name":
    db      => $dbname,
    command => 'select 1',
    unless  => "select 1 from pg_catalog.pg_tables where schemaname = '$name'",
  }
}
