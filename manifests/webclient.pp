class i2b2::webclient
(
  $webclient_dir,
  $domains = $i2b2::params::webclient_domains
) inherits i2b2::params
{
  $webclient_zip = "$intermediate_dir/i2b2webclient-$version.zip"

  Exec {
    path => '/bin:/usr/bin',
  }

  wget::fetch { $webclient_zip :
    source      => "http://files.thehyve.net/i2b2-$version/i2b2webclient-$version.zip",
    destination => $webclient_zip,
  }
  ~>
  exec { "create-empty-dir-$webclient_dir" :
    command     => "rm -rf '$webclient_dir' && mkdir '$webclient_dir'",
    refreshonly => true,
  }
  ~>
  exec { "extract-$webclient_zip":
    cwd         => $webclient_dir,
    command     => "bsdtar -xf '$webclient_zip' --strip-components=1",
    refreshonly => true,
  }
  ->
  file { "$webclient_dir/i2b2_config_data.js" :
    ensure  => file,
    content => template('webclient/i2b2_config_data.js.erb'),
  }

  file { $webclient_zip:
    require => Wget::Fetch[$webclient_zip],
  }
}
