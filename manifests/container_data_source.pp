define i2b2::container_data_source(
  $user,
  $password,
  $max_conn = 30,
  $min_idle_conn = 2,
  $max_idle_conn = 4,
  $type = 'javax.sql.DataSource',
) {
  include i2b2::params

  $jdbc_driver    = $::i2b2::params::database_driver
  $jdbc_url       = $::i2b2::params::database_jdbc_url
  $implementation = $::i2b2::params::container_data_source_implementation

  if $implementation != '' {
    create_resources($implementation, {
      "$name" => {
        jdbc_driver   => $jdbc_driver,
        jdbc_url      => $jdbc_url,
        type          => $type,
        username      => $user,
        password      => $password,
        max_conn      => $max_conn,
        min_idle_conn => $min_idle_conn,
        max_idle_conn => $max_idle_conn,
      }
    })
  } # else assume the user already exists

}
