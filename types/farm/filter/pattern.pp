# Filter Pattern attributes hash.
# @summary A hash of filter pattern attributes.
#   Used to configure confgure the different options for a filter parameter.
#
type Dispatcher::Farm::Filter::Pattern = Struct[
  {
    regex   => Boolean,
    pattern => String
  }
]
