define i2b2::cell_schemas::common(
  $ant_script_dir,
  $database_user, # can be managed by us
  $database_password,
  $target_infix,
  $additional_targets = [],
) {
  require i2b2
  require i2b2::params
  require i2b2::createdb_files

  $db_properties = "${::i2b2::params::intermediate_dir}/db_${database_user}.properties"
  file { $db_properties:
    ensure  => file,
    content => template('i2b2/db.properties.erb')
  }

  $ant_target_version = $::i2b2::params::ant_target_version

  $db_properties_final = "${::i2b2::createdb_files::base}/$ant_script_dir/db.properties"

  $joined_additional_targets = join($additional_targets, ' ')

  i2b2::database_user { $database_user:
    username => $database_user,
    password => $database_password,
  } ->
  exec { "run ant for creating schema for user $database_user":
    command     => "cp '$db_properties' '$db_properties_final' && \
                    ant -f '${::i2b2::createdb_files::base}/$ant_script_dir/data_build.xml' \
                    create_${target_infix}_tables_release_${::i2b2::params::ant_target_version} $joined_additional_targets",
    path        => '/bin:/usr/bin',
    refreshonly => true, # refreshed by database_cell_detect_implementation
    require     => File[$db_properties],
  }

  if $i2b2::params::database_cell_detect_implementation != '' {
    create_resources($i2b2::params::database_cell_detect_implementation, {
      "$database_user"    => { # schema has same name as user
        database_user     => $database_user,
        database_password => $database_password,
        notify            => Exec["run ant for creating schema for user $database_user"],
        require           => I2b2::Database_user[$database_user],
      }
    })
  }

  i2b2::container_data_source { $database_user:
    user     => $database_user,
    password => $database_password,
  }
}
