define i2b2::i2b2_user(
  $ensure    = present,
  $username  = $name,
  $password  = '',
  $full_name = '',
  $status    = 'A'
) {
  require i2b2::cell_schemas::pm
  include i2b2::params

  validate_re($ensure, '^present|absent$')

  table_row { "i2b2 user $username":
    ensure   => $ensure,
    table    => "$params::pm_db_user.pm_user_data",
    identity => {
      user_id => $username,
    },
    values   => {
      full_name => $full_name,
      password  => i2b2_password_hash($password),
      status_cd => $status,
    }
  }
}
