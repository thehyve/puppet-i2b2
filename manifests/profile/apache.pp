class i2b2::profile::apache inherits i2b2::params
{
  $webroot_dir = $i2b2::params::webroot_dir

  ensure_resource('package', 'php5-curl', {'ensure' => present})

  class {'::apache' :
    default_vhost => false,
    mpm_module    => 'prefork',
  }

  include ::apache::mod::php

  apache::vhost { "http-$i2b2::params::external_hostname":
    port          => 80,
    docroot       => $webroot_dir,
    redirect_dest => "https://$i2b2::params::external_hostname/",
  }

  apache::vhost { "https-$i2b2::params::external_hostname":
    port    => 443,
    docroot => $webroot_dir,
    ssl     => true,
    headers => 'set Strict-Transport-Security "max-age=15768000"',
  }

  include ::i2b2::webclient
  include ::i2b2::admin
}
