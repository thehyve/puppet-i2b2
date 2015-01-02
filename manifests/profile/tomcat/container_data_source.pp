define i2b2::profile::tomcat::container_data_source(
  $jdbc_driver,
  $jdbc_url,
  $type,
  $username,
  $password,
  $max_conn,
  $min_idle_conn,
  $max_idle_conn,
) {
  include i2b2::params

  $resources_file = "$i2b2::params::intermediate_dir/tomcat_resources.xml.fragments"

  concat::fragment { "$resources_file-$name":
    target  => $resources_file,
    content => template('i2b2/tomcat/tomcat_data_source.xml.erb'),
  }

}
