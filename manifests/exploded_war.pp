class i2b2::exploded_war inherits params {
  $axis_url = "http://files.thehyve.net/axis2-$params::axis_version-war.zip"
  $axis_war = "$params::intermediate_dir/axis2-$params::axis_version-war.zip"

  $dir = $params::exploded_war_dir

  Exec {
    path => '/bin:/usr/bin'
  }

  file { $dir:
    ensure => directory,
    owner  => $params::user,
  } ->
  wget::fetch { $axis_war:
    source      => $axis_url,
    destination => $axis_war,
  } ~>
  exec { "clean-$dir":
    cwd         => $dir,
    command     => 'find . -mindepth 1 -maxdepth 1 -exec rm -rf \'{}\' \\;',
    refreshonly => true,
  } ->
  exec { "extract $axis_war":
    cwd         => $dir,
    user        => $params::user,
    command     => "bsdtar -xOf '$axis_war' axis2.war | bsdtar -xf -",
    creates     => "$dir/WEB-INF",
    provider    => shell,
  }

  file { $axis_war:
    require => Wget::Fetch[$axis_war],
  }
}