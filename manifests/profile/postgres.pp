class i2b2::profile::postgres inherits i2b2::params {
  include postgresql::server
  include i2b2::profile::database_data

  postgresql::server::database { $::i2b2::params::database_name: }

  Postgresql::Server::Database[$::i2b2::params::database_name]
  ->
  I2b2::Profile::Postgresql::Database_user <| |>
  ->
  Table_row <| |>

  $database_connect_params = {
    dbname => $::i2b2::params::database_name,
  }

  postgresql::server::config_entry { 'max_connections' :
    value => 200,
  }

  Table_row <| |> {
    connect_params => $database_connect_params,
    system_user    => $postgresql::params::user,
  }

  I2b2_user_roles <| |> {
    connect_params => $database_connect_params,
    system_user    => $postgresql::params::user,
  }
}
