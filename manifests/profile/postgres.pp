class i2b2::profile::postgres inherits i2b2::params {
  include postgresql::server
  include i2b2::profile::database_data

  postgresql::server::database { $params::database_name: }

  Postgresql::Server::Database[$params::database_name]
  ->
  I2b2::Profile::Postgresql::Database_user <| |>
  ->
  Table_row <| |>

  Table_row <| |> {
    connect_params => $params::database_connect_params,
    system_user    => $postgresql::params::user,
  }
}
