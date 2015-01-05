define i2b2::i2b2_user(
  $username  = $name,
  $ensure    = present,
  $password  = '',
  $full_name = '',
  $status    = 'A'
) {
  require i2b2::cell_schemas::pm
  include i2b2::params

  validate_re($ensure, '^present|absent$')

  table_row { "i2b2 user $username":
    table    => "$params::pm_db_user.pm_user_data",
    ensure   => $ensure,
    identity => { user_id => $username, },
    values   => {
      full_name => $full_name,
      password  => md5($password),
      status_cd => $status,
    }
  }
}
