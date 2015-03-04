class i2b2::webclient
(
  $webclient_dir,
  $domains = $i2b2::params::webclient_domains,
  $css_sheets = $i2b2::params::additional_css_sheets,
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
    content => template('i2b2/webclient_config_data.js.erb'),
  }

  file { "$webclient_dir/proxy.php" :
    ensure  => file,
    content => template('i2b2/proxy.php.erb'),
  }

  file { "$intermediate_dir/css_declarations.xml":
    ensure  => file,
    content => template('i2b2/css_declarations.erb'),
    require => Exec[ "extract-$webclient_zip" ],
  }
  ~>
  exec { 'insert-css' :
    cwd     => $webclient_dir,
    command => "sed -i -e '/<\\/head>/r $intermediate_dir/css_declarations.xml' -e //N default.htm",
    unless  => "test ! -s $intermediate_dir/css_declarations.xml ||  grep -f $intermediate_dir/css_declarations.xml default.htm",
  }

  file { $webclient_zip:
    require => Wget::Fetch[$webclient_zip],
  }
}
