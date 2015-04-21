class i2b2::params(
  $intermediate_dir = '/opt/i2b2_intermediate',
  $version = '1704',
  $ant_target_version = '1-7',

  $user = 'i2b2',
  $manage_user = false,

  $manage_packages = true,

  $webroot_dir = '/opt/i2b2_webroot',
  $axis_version = '1.6.2',
  $exploded_war_dir = '/opt/i2b2',
  $axis_admin_password,

  $context = 'i2b2',
  $local_base_url = 'http://localhost:8080',
  $external_hostname = $::fqdn, # right now for the webserver vhost only (webclient)
  $external_base_url_tomcat = "http://${::fqdn}:8080",

  # connection details for the database; does not have to be local
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

  # If defined, when a cell is declared, do not attempt to register it.
  # Instead, export a resource with this tag.
  $export_cell_registrations_tag = '',

  # pool settings
  $default_pool_settings = {
    max_conn      => 30,
    min_idle_conn => 2,
    max_idle_conn => 6,
  },
  $pool_settings = {}, # like default_pool_settings

  # logging
  $log_dir,
  $root_logging_level = 'DEBUG',

  $container_data_source_implementation = '', # e.g. i2b2::profile::tomcat::container_data_source

  # local db only
  $database_user_implementation = '', # e.g. 'i2b2::profile::postgresql::database_user'
  $database_cell_detect_implementation = '', # e.g. 'i2b2::profile::postgresql::no_cell_data_detect'

  # specified like this [ { local => true, filename => 'test_local' }, { local =>false, filename => 'http://testremote.com/remote.css' } ]
  $additional_css_sheets = [],

  $admin_proxy_prefixes = '',     # array, '' for default
  $webclient_proxy_prefixes = '', # array, '' for default
) {
  $local_url = "$local_base_url/$context"
  $external_url = "$external_base_url_tomcat/$context"

  $default_domains =
  [
    {
      domain => 'i2b2demo',
      name => 'HarvardDemo',
      urlCellPM => 'http://services.i2b2.org/i2b2/services/PMService/',
      allowAnalysis => true,
      debug => true,
    },
    {
      domain        => $hive_domain_name,
      name          => "Hive $hive_domain_name",
      urlCellPM     => "$external_url/services/PMService/",
      allowAnalysis => true,
      debug         => true,
    },
  ]
  $webclient_domains = hiera('i2b2::params::webclient_domains', $default_domains)
  $webclient_dir = "$webroot_dir/webclient"

  $admin_domains = hiera('i2b2::params::admin_domains', $default_domains)
  $admin_dir = "$webroot_dir/admin"

  if $manage_packages {
    if $::osfamily == 'debian' {
      $bsdtar_package = 'bsdtar'
      $java_package = 'openjdk-7-jdk'
      $ant_package = 'ant'
      $gems_deps_packages = ['libpq-dev', 'ruby-dev']
    }
  }
}
