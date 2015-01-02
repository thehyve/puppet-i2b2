class i2b2::createdb_files inherits i2b2::params {
  require i2b2

  $createdb_zip = "$params::intermediate_dir/i2b2createdb-$params::version.zip"

  $dir = "$intermediate_dir/i2b2createdb-$params::version"
  $base = "$dir/NewInstall"

  Exec {
    path => '/bin:/usr/bin'
  }

  file { $dir:
    ensure => directory,
  } ->
  wget::fetch { $createdb_zip:
    source      => "http://files.thehyve.net/i2b2-$params::version/i2b2createdb-$params::version.zip",
    destination => $createdb_zip,
    require     => File[$params::intermediate_dir],
  } ~>
  exec { "clean-$dir":
    cwd         => $dir,
    command     => 'rm -rf NewInstall Upgrade',
    refreshonly => true,
  } ~>
  exec { "extract-$createdb_zip":
    cwd         => $dir,
    command     => "bsdtar -xf '$createdb_zip' --strip-components=2 && \
                    test -d '$base'",
    refreshonly => true,
  } ->
  file { $base:
    ensure => directory
  }

  Wget::Fetch[$createdb_zip]
  ->
  file { $createdb_zip: }

  # define these resources to avoid auto dependencies of modified_properties_file working
  $properties_files = [
    "$dir/edu.harvard.i2b2.im/build.properties",
    "$dir/edu.harvard.i2b2.workplace/build.properties",
    "$dir/edu.harvard.i2b2.pm/build.properties",
    "$dir/edu.harvard.i2b2.crc/build.properties",
    "$dir/edu.harvard.i2b2.fr/build.properties",

    "$dir/edu.harvard.i2b2.ontology/build.properties",
    "$dir/edu.harvard.i2b2.ontology/etc/spring/ontology.properties",
    "$dir/edu.harvard.i2b2.ontology/etc/spring/ontology_application_directory.properties",
  ]

  Exec["extract-$createdb_zip"]
  ->
  file { $properties_files: }

}
