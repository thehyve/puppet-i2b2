class i2b2::cell_data::default_admin {
  include i2b2::params

  i2b2::i2b2_user { 'i2b2':
    full_name => 'i2b2 Admin',
    password  => $params::default_admin_password,
  }
}
