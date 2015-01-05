class i2b2::params(
  $intermediate_dir = '/opt/i2b2_intermediate',
  $version = '1704',
  $ant_target_version = '1-7',

  $user = 'i2b2',
  $manage_user = false,

  $webclient_dir = '/opt/i2b2_webclient',
  $axis_version = '1.6.2',
  $exploded_war_dir = '/opt/i2b2',

  $context = 'i2b2',
  $local_base_url = 'http://localhost:8080',
  $external_base_url = "http://${::fqdn}",

  # connection details for the database; doesn't have to be local
  $database_type, # e.g. postgresql
  $database_driver, # e.g. org.postgresql.Driver
  $database_name = 'i2b2',
  $database_host = 'localhost',
  $database_jdbc_url, # e.g. jdbc:postgresql://localhost/i2b2; must be consistent with database_{name, host}
  $database_jdbc_jar_url, # e.g. 'http://jdbc.postgresql.org/download/postgresql-9.3-1102.jdbc41.jar',
  $database_system_user, # e.g. postgres

  $service_user = 'AGG_SERVICE_ACCOUNT',
  $service_user_password,
  $default_admin_password, # user is always i2b2

  # general hive data
  # only one domain can be managed
  $hive_domain_id = 'i2b2',
  $hive_help_url = 'http://www.i2b2.org',
  $hive_domain_name = 'i2b2default',
  $hive_environment = 'PRODUCTION',

  # db users and password
  $pm_db_user = 'i2b2pm',
  $pm_db_password = 'i2b2pm',

  $hive_db_user = 'i2b2hive',
  $hive_db_password = 'i2b2hive',

  # logging
  $log_dir,
  $root_logging_level = 'DEBUG',

  $container_data_source_implementation = '', # e.g. i2b2::profile::tomcat::container_data_source

  # local db only
  $database_user_implementation = '', # e.g. 'i2b2::profile::postgresql::database_user'
  $database_cell_detect_implementation = '', # e.g. 'i2b2::profile::postgresql::no_cell_data_detect'
) {
  $local_url = "$local_base_url/$context"
  $external_url = "$external_base_url/$context"

  $database_connect_params = {
    dbname => $database_name,
  }
}
