# Glob rule attributes hash.
# @summary A hash of glob rule attributes.
#   Used to configure glob rules for different Farm Cache sections.
#
type Dispatcher::Farm::GlobRule = Struct[
  {
    rank  => Integer[0],
    glob  => String,
    allow => Boolean,
  }
]
