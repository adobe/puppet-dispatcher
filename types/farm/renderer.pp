# Renderer attributes hash.
# @summary A hash of renderer attributes.
#   Used to configure the `/renderer` parameter instance of a Farm.
#
type Dispatcher::Farm::Renderer = Struct[
  {
    hostname        => Stdlib::Host,
    port            => Stdlib::Port,
    timeout         => Optional[Integer[0]],
    receive_timeout => Optional[Integer[0]],
    ipv4            => Optional[Boolean],
    secure          => Optional[Boolean],
    always_resolve  => Optional[Boolean],
  }
]
