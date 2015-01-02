define i2b2::profile::postgresql::database_user(
  $username,
  $password,
) {
  include ::i2b2::params

  $dbname = $::i2b2::params::database_name

  Postgresql_psql {
    db => $dbname
  }

  postgresql::server::role { $username:
    password_hash => postgresql_password($username, $password),
  } ->
  postgresql_psql { "i2b2-create-schema-$username":
    unless  => "select 1 from pg_catalog.pg_namespace where nspname = '$username'",
    command => "create schema \"$username\" authorization \"$username\"",
  }

  postgresql_psql { "i2b2-set-${username}-searchpath":
    command     => "alter role \"$username\" SET search_path=$username,public",
    refreshonly => true, # would be better with unless; the info is in pg_user.use_config
    subscribe   => Postgresql::Server::Role[$username],
  }

  postgresql_psql { "i2b2-grant-${username}-connect-on-${dbname}":
    unless  => "select 1 from \
                (select aclexplode(datacl) from pg_catalog.pg_database where datname = '$dbname') AS R(rec) \
                where (R.rec).grantee = (select oid from pg_roles where rolname = '$username') \
                and (R.rec).privilege_type = 'CONNECT'",
    command => "grant connect on database \"$dbname\" TO \"$username\"",
    require => Postgresql::Server::Role[$username],
  }
}
