class i2b2::profile::postgresql::i2b2_params(
  $database_name = 'i2b2' # we cannot reference i2b2::params in this class
) {
  $data = {
    database_type                       => 'postgresql',
    database_driver                     => 'org.postgresql.Driver',
    database_jdbc_url                   => "jdbc:postgresql://localhost/$database_name",
    database_jdbc_jar_url               => 'http://jdbc.postgresql.org/download/postgresql-9.3-1102.jdbc41.jar',
    database_user_implementation        => 'i2b2::profile::postgresql::database_user',
    database_cell_detect_implementation => 'i2b2::profile::postgresql::no_cell_data_detect',
    database_system_user                => 'postgres'
  }
}
