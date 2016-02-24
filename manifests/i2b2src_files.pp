class i2b2::i2b2src_files inherits i2b2::params {
  require i2b2

  $url = "http://files.thehyve.net/i2b2-$::i2b2::params::version/i2b2core-src-$::i2b2::params::version.zip"
  $i2b2source_zip = "$::i2b2::params::intermediate_dir/i2b2core-src-$::i2b2::params::version.zip"

  $dir = "$::i2b2::params::intermediate_dir/i2b2core-src-$::i2b2::params::version"

  Exec {
    path => '/bin:/usr/bin'
  }

  file { $dir:
    ensure => directory,
    owner  => $::i2b2::params::user,
  } ->
  wget::fetch { $i2b2source_zip:
    source      => $url,
    destination => $i2b2source_zip,
    require     => File[$::i2b2::params::intermediate_dir],
  } ~>
  exec { "clean-$dir":
    cwd         => $dir,
    command     => 'find -delete',
    refreshonly => true,
    provider    => shell,
  } ->
  exec { "extract-$i2b2source_zip":
    cwd     => $dir,
    user    => $::i2b2::params::user,
    command => "bsdtar -xf '$i2b2source_zip'",
    creates => "$dir/edu.harvard.i2b2.server-common"
  }

  file { $i2b2source_zip:
    require => Wget::Fetch[$i2b2source_zip],
  }

  $diff_file = "$::i2b2::params::intermediate_dir/ServiceLocator.java.diff"
  file { $diff_file:
    source => 'puppet:///modules/i2b2/ServiceLocator.java.diff',
  }

  $serviceLocator_file = "$dir/edu.harvard.i2b2.server-common/src/core/edu/harvard/i2b2/common/util/ServiceLocator.java"
  exec { "patch-$serviceLocator_file":
    cwd      => $dir,
    user     => $::i2b2::params::user,
    command  => "patch -p2 < '$diff_file'",
    unless   => "grep nameInCompEnv '$serviceLocator_file'",
    provider => shell,
    require  => [
      File[$diff_file],
      Exec["extract-$i2b2source_zip"],
    ],
  }
}
