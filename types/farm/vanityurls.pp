# Vanity URL attributes hash.
# @summary A hash of vanity url attributes.
#   Used to configure the `/vanith_url` parameter instance of a Farm.
#
type Dispatcher::Farm::VanityUrls = Struct[
  {
    file  => Stdlib::Absolutepath,
    delay => Integer[0],
  }
]

