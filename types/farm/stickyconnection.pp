# StickyConnection attributes hash.
# @summary A hash of Statistic attributes.
#   Used to configure the `/statistics` parameter instance of a Farm.
#
type Dispatcher::Farm::StickyConnection = Struct[
  {
    paths               => Array[String],
    Optional[domain]    => String,
    Optional[http_only] => Boolean,
    Optional[secure]    => Boolean,
  }
]
