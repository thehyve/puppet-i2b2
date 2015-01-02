class i2b2::jdbc_driver {
  include i2b2

  $jar_url = $::i2b2::params::database_jdbc_jar_url

  $file_name = inline_template('<%= File.basename(@jar_url) %>')
  $file_path = "$::i2b2::params::intermediate_dir/$file_name"

  wget::fetch { 'axis_war':
    source      => $jar_url,
    destination => "$file_path",
    require     => File[$::i2b2::params::intermediate_dir],
  } ->
  file { $file_path: }

}
