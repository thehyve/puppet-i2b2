class i2b2::profile::apache(
  $servername      = $i2b2::params::external_hostname,
  $ssl_cert_source = '',
  $ssl_key_source  = ''
) inherits i2b2::params {
  $webroot_dir = $i2b2::params::webroot_dir

  class {'::apache' :
    default_vhost => false,
    mpm_module    => 'prefork',
  }

  include ::apache::mod::php

  package { $i2b2::params::php_curl_package: }

  apache::vhost { "http-$servername":
    port          => 80,
    docroot       => $webroot_dir,
    redirect_dest => "https://$servername/",
  }

  $certs_dir = $apache::params::ssl_certs_dir
  validate_absolute_path($certs_dir)
  validate_absolute_path($apache::params::default_ssl_key)

  $cert_file = "$certs_dir/i2b2.cert"
  $key_file_parent = dirname($apache::params::default_ssl_key)
  $key_file = "$key_file_parent/i2b2.key"

  if $ssl_cert_source != '' {
    validate_string($ssl_cert_source)
    validate_string($ssl_key_source)
    validate_re($ssl_key_source, '..') # must be non-empty (2 char min)

    file { $cert_file:
      source  => $ssl_cert_source,
      require => Class['::Apache']
    } ~> Class['::apache::service']

    file { $key_file:
      source  => $ssl_key_source,
      mode    => '0440',
      owner   => 'root',
      group   => $i2b2::params::ssl_key_group,
      require => Class['::apache']
    } ~> Class['::apache::service']
  }

  $ssl_ca_value = $ssl_cert_source ? {
    ''      => undef,
    default => $cert_file
  }
  $ssl_cert_value = $ssl_ca_value
  $ssl_key_value = $ssl_cert_source ? {
    ''      => undef,
    default => $key_file,
  }

  apache::vhost { "https-$servername":
    servername => $servername,
    port       => 443,
    docroot    => $webroot_dir,
    ssl        => true,
    headers    => 'set Strict-Transport-Security "max-age=15768000"',
    ssl_ca     => $ssl_ca_value,
    ssl_cert   => $ssl_cert_value,
    ssl_key    => $ssl_key_value,
  }

  include ::i2b2::webclient
  include ::i2b2::admin
}
