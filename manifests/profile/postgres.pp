class i2b2::profile::postgres inherits i2b2::params {
  include postgresql::server

  postgresql::server::database { $params::database_name: }

  Postgresql::Server::Database[$params::database_name]
  ->
  I2b2::Profile::Postgresql::Database_user <| |>
  ->
  Table_row <| |>

  Table_row <| |> {
    system_user => $postgresql::params::user,
  }

#  I2b2::Profile::Postgresql::Database_user <| |>
#  ->
#  I2b2::Cell_schemas::Common <| |>
}
