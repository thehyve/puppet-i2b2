class i2b2::webclient_root(

) inherits i2b2::params {
  require i2b2

  $webclient_zip = "$intermediary_files_dir/i2b2webclient-$version.zip"

  Exec {
    path => '/bin:/usr/bin',
  }

  wget::fetch { $webclient_zip:
    source      => "http://files.thehyve.net/i2b2-$version/i2b2webclient-$version.zip",
    destination => $webclient_zip,
  } ~>
  exec { "create-clean-$webclient_dir":
    exec => "rm -rf '$webclient_dir' && "
  } ~>
  exec { "extract-$webclient_zip":
    exec        => "bsdtar -C '$webclient_dir' \
                   --strip-components=1 -xf '$webclient_zip'",
    refreshonly => true,
  }


}
