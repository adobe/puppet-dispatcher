# Filter attributes hash.
# @summary A hash of filter attributes.
#   Used to configure the `/filter` parameter instance of a Farm.
#
type Dispatcher::Farm::Filter = Struct[
  {
    rank      => Integer[0],
    allow     => Boolean,
    Optional[url]       => Dispatcher::Farm::Filter::Pattern,
    Optional[method]    => Dispatcher::Farm::Filter::Pattern,
    Optional[query]     => Dispatcher::Farm::Filter::Pattern,
    Optional[protocol]  => Dispatcher::Farm::Filter::Pattern,
    Optional[path]      => Dispatcher::Farm::Filter::Pattern,
    Optional[selectors] => Dispatcher::Farm::Filter::Pattern,
    Optional[extension] => Dispatcher::Farm::Filter::Pattern,
    Optional[suffix]    => Dispatcher::Farm::Filter::Pattern,
  }
]

