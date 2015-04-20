class i2b2::axis2_password(
  $password        = $i2b2::params::axis_admin_password,
  $exploded_war_dir = $i2b2::params::exploded_war_dir,
) inherits i2b2::params {

  require ::i2b2::cells::hive

  augeas { 'replace-axis-password' :
    incl    => "$exploded_war_dir/WEB-INF/conf/axis2.xml",
    lens    => 'Xml.lns',
    context => "/files/$exploded_war_dir/WEB-INF/conf/axis2.xml/axisconfig",
    changes => "set parameter[./#attribute/name='password']/#text $password"
  }
}
