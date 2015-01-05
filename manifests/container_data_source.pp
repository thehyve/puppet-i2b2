define i2b2::container_data_source(
  $user,
  $password,
  $type = 'javax.sql.DataSource',
) {
  include i2b2::params

  $jdbc_driver    = $::i2b2::params::database_driver
  $jdbc_url       = $::i2b2::params::database_jdbc_url
  $implementation = $::i2b2::params::container_data_source_implementation

  if $::i2b2::params::pool_settings[$name] {
    $per_pool_settings = $::i2b2::params::pool_settings[$name]
  } else {
    $per_pool_settings = {}
  }

  $default_pool_settings = $::i2b2::params::default_pool_settings

  $per_pool_max_conn = $per_pool_settings['max_conn']
  $def_max_conn      = $default_pool_settings['max_conn']
  if $per_pool_max_conn {
    $max_conn = $per_pool_max_conn
  } elsif $def_max_conn {
    $max_conn = $def_max_conn
  } else {
    fail("Could not find max connections setting for pool $name")
  }

  $per_pool_min_idle_conn = $per_pool_settings['min_idle_conn']
  $def_min_idle_conn      = $default_pool_settings['min_idle_conn']
  if $per_pool_min_idle_conn {
    $min_idle_conn = $per_pool_min_idle_conn
  } elsif $def_min_idle_conn {
    $min_idle_conn = $def_min_idle_conn
  } else {
    fail("Could not find min idle connections setting for pool $name")
  }

  $per_pool_max_idle_conn = $per_pool_settings['max_idle_conn']
  $def_max_idle_conn      = $default_pool_settings['max_idle_conn']
  if $per_pool_max_idle_conn {
    $max_idle_conn = $per_pool_max_idle_conn
  } elsif $def_max_idle_conn {
    $max_idle_conn = $def_max_idle_conn
  } else {
    fail("Could not find max idle connections setting for pool $name")
  }

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
