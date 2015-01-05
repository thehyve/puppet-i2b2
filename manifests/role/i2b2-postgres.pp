class i2b2::role::i2b2-postgres {
  # create_resources will hide the proper errors
  # protect against a common one
  #validate_string(hiera('i2b2::params::service_user_password'))

  include i2b2::profile::postgresql::i2b2_params
  include i2b2::profile::tomcat::i2b2_params
  $merged_params = merge(
    # XXX
    {
      service_user_password => 'foobar',
    },
    $i2b2::profile::tomcat::i2b2_params::data,
    $i2b2::profile::postgresql::i2b2_params::data)

  $t = {
    'i2b2::params' => $merged_params,
  }
  create_resources('class', $t)

  include i2b2::profile::postgres
  include i2b2::profile::tomcat

  # database must be set up before
  Class['I2b2::Profile::Postgres'] -> Class['I2b2::Profile::Tomcat']
}
