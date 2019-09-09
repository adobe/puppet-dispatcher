# AuthChecker attributes hash.
# @summary A hash of AuthChecker attributes.
#   Used to configure the `/auth_checker` parameter instance of a Farm.
#
type Dispatcher::Farm::AuthChecker = Struct[
  {
    url     => Stdlib::Absolutepath,
    filters => Array[Dispatcher::Farm::GlobRule],
    headers => Array[Dispatcher::Farm::GlobRule],
  }
]
