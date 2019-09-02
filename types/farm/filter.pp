# Filter attributes hash.
# @summary A hash of filter attributes.
#   Used to configure the `/filter` parameter instance of a Farm.
#
type Dispatcher::Farm::Filter = Struct[
  {
    rank      => Integer[0],
    allow     => Boolean,
    url       => Optional[Dispatcher::Farm::Filter::Pattern],
    method    => Optional[Dispatcher::Farm::Filter::Pattern],
    query     => Optional[Dispatcher::Farm::Filter::Pattern],
    protocol  => Optional[Dispatcher::Farm::Filter::Pattern],
    path      => Optional[Dispatcher::Farm::Filter::Pattern],
    selectors => Optional[Dispatcher::Farm::Filter::Pattern],
    extension => Optional[Dispatcher::Farm::Filter::Pattern],
    suffix    => Optional[Dispatcher::Farm::Filter::Pattern],
  }
]

