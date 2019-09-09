# Renderer attributes hash.
# @summary A hash of renderer attributes.
#   Used to configure the `/renderer` parameter instance of a Farm.
#
type Dispatcher::Farm::Renderer = Struct[
  {
    hostname                  => Stdlib::Host,
    port                      => Stdlib::Port,
    Optional[timeout]         => Integer[0],
    Optional[receive_timeout] => Integer[0],
    Optional[ipv4]            => Boolean,
    Optional[secure]          => Boolean,
    Optional[always_resolve]  => Boolean,
  }
]
