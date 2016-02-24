class i2b2::cell_data::service_user {
  include i2b2::params

  i2b2::i2b2_user { $::i2b2::params::service_user:
    full_name => 'AGG_SERVICE_ACCOUNT',
    password  => $::i2b2::params::service_user_password,
  }
}
