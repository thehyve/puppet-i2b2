define i2b2::database_user(
  $username,
  $password,
) {
  include ::i2b2::params

  $implementation = $::i2b2::params::database_user_implementation

  if $implementation != '' {
    create_resources($implementation, {
      "$title" => {
        username => $username,
        password => $password,
      }
    })
  } # else assume the user already exists
}
