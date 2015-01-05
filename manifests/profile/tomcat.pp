class i2b2::profile::tomcat(
  $number = '0', # has to be in sync with params::local_base_url
  $context_file_path = "/opt/i2b2_context.xml",
) inherits i2b2::params {

  include i2b2
  include ::i2b2::jdbc_driver
  include ::i2b2::profile::cells

  tomcat_distr::user { 'i2b2':
    webapp_base => '/home'
  }

  class { '::i2b2::profile::tomcat::context_file':
    path => $context_file_path,
  } ->
  tomcat_distr::webapp { 'i2b2':
    username        => $params::user,
    webapp_base     => '/home',
    context         => $params::context,
    number          => $number,
    java_opts       => "-Djava.awt.headless=true -Xmx1300M",
    source          => $context_file_path,
    extra_libs      => [$::i2b2::jdbc_driver::file_path],
    manage_user     => false,
    service_require => [
      Class['I2b2::Profile::Cells'],
      Class['I2b2::Jdbc_driver'],
    ],
  }

  I2b2::Cells::Common <| |>
  ~>
  Service['i2b2']
}
