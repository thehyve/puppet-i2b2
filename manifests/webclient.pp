class i2b2::webclient
(
  $webclient_dir = $i2b2::params::webclient_dir,
  $domains       = $i2b2::params::webclient_domains,
  $css_sheets    = $i2b2::params::additional_css_sheets,
  $prefixes      = $i2b2::params::webclient_proxy_prefixes,
) inherits i2b2::params
{
  $webclient_zip = "$intermediate_dir/i2b2webclient-$version.zip"
  $admin_only = false # for template config_data.js.erb

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
  ->
  file { $webclient_dir:
    ensure => directory,
  }

  exec { "extract-$webclient_zip":
    cwd     => $webclient_dir,
    command => "bsdtar -xf '$webclient_zip' --no-same-owner --no-same-permissions --strip-components=1",
    unless  => "test -d '$webclient_dir/help'"
  }
  ->
  file { "$webclient_dir/i2b2_config_data.js" :
    ensure  => file,
    content => template('i2b2/config_data.js.erb'),
  }

  file { "$webclient_dir/proxy.php" :
    ensure  => file,
    content => template('i2b2/proxy.php.erb'),
  }

  file { "$intermediate_dir/css_declarations.xml":
    ensure  => file,
    content => template('i2b2/css_declarations.erb'),
    require => Exec["extract-$webclient_zip"],
  }
  ~>
  exec { 'insert-css' :
    cwd         => $webclient_dir,
    command     => "bsdtar -xf '$webclient_zip' \
                    --no-same-owner --no-same-permissions --strip-components 1 webclient/default.htm \
                    && sed -i -e '/<\\/head>/r $intermediate_dir/css_declarations.xml' -e //N default.htm",
    refreshonly => true,
    subscribe   => Exec["extract-$webclient_zip"]
  }

  file { $webclient_zip:
    require => Wget::Fetch[$webclient_zip],
  }

  if $prefixes != '' {
    $proxy_prefixes = $prefixes
  } else {
    $proxy_prefixes = i2b2_domains_to_prefixes($domains)
  }

  Exec["extract-$webclient_zip"]
  ->
  file { "$webclient_dir/index.php":
    content => template('i2b2/index.php.erb'),
  }
}
