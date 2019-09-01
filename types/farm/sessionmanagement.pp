# SessionManagement attributes hash.
# @summary A hash of sessionmanagement attributes.
#   Used to configure the `/sessionmanagement` parameter of a Farm.
#
type Dispatcher::Farm::SessionManagement = Struct[
  {
    directory => Stdlib::Absolutepath,
    encode    => Optional[String],
    header    => Optional[String],
    timeout   => Optional[Integer[0]],
  }
]
