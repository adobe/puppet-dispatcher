# SessionManagement attributes hash.
# @summary A hash of sessionmanagement attributes.
#   Used to configure the `/sessionmanagement` parameter of a Farm.
#
type Dispatcher::Farm::SessionManagement = Struct[
  {
    directory         => Stdlib::Absolutepath,
    Optional[encode]  => String,
    Optional[header]  => String,
    Optional[timeout] => Integer[0],
  }
]
