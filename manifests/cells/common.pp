define i2b2::cells::common(
  $cell_source_dir,
  $user,
  $file_to_check, # to determine if the cell was already installed

  # for registering the local cell with the PM cell
  $pm_cell_user = absent,
  $cell_id = absent,
  $cell_details = absent,

  # for bootstrap data source
  $bootstrap_prefix = '',
  $bootstrap_user = '',
  $bootstrap_password = '',

  $app_dir_prop_file = absent,
  $app_dir_key = absent,
  $ant_build_xml = 'master_build.xml',
  $war_name = 'i2b2',
  $targets = ['clean', 'build-all', 'deploy'],
) {
  include i2b2::params
  require i2b2::pseudo_jboss

  $pseudo_jboss_home = $i2b2::pseudo_jboss::dir

  $joined_targets = join($targets, ' ')

  modified_properties_file { "$cell_source_dir/build.properties":
    values => {
      'jboss.home'     => $pseudo_jboss_home,
      'axis2.war.name' => $war_name,
    },
    notify => Exec["install-$name"]
  }

  unless $app_dir_prop_file == absent {
    modified_properties_file { $app_dir_prop_file:
      values => {
        "$app_dir_key" => "$i2b2::pseudo_jboss::war_dir/WEB-INF/classes"
      },
      notify => Exec["install-$name"]
    }
  }

  Exec {
    path => '/bin:/usr/bin'
  }

  exec { "check-cell-installed-$name":
    command => 'true',
    unless  => "test -f $i2b2::params::exploded_war_dir/WEB-INF/lib/$file_to_check",
  }
  ~>
  exec { "install-$name":
    cwd         => $cell_source_dir,
    user        => $user,
    command     => "ant -f '$ant_build_xml' $joined_targets",
    refreshonly => true,
  }

  Table_row {
    connect_params => $params::database_connect_params,
    system_user    => $params::system_user,
  }

  if $bootstrap_prefix != '' {
    $bootstrap_ds_name   = "${bootstrap_prefix}BootStrapDS"
    $bootstrap_ds_params = {
      user     => $bootstrap_user,
      password => $bootstrap_password,
    }
    ensure_resource('i2b2::container_data_source',
      $bootstrap_ds_name, $bootstrap_ds_params)
  }

  unless $cell_details == absent {
    validate_string($cell_details['name'])
    validate_string($cell_details['url'])

    Class['I2b2::Cell_schemas::Pm']
    ->
    table_row { "$name-cell-data":
      table    => "$pm_cell_user.pm_cell_data",
      identity => {
        'cell_id'      => $cell_id,
        'project_path' => '/',
      },
      values => merge(
        {
          'method_cd'    => 'REST',
          'can_override' => '1',
          'status_cd'    => 'A',
        },
        $cell_details
      ),
    }
  }



}
