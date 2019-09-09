# Cache attributes hash.
# @summary A hash of cache attributes.
#   Used to configure the `/cache` parameter instance of a Farm.
#
type Dispatcher::Farm::Cache = Struct[
  {
    docroot                        => Stdlib::Absolutepath,
    rules                          => Array[Dispatcher::Farm::GlobRule],
    allowed_clients                => Array[Dispatcher::Farm::GlobRule],
    Optional[statfile]             => Stdlib::Absolutepath,
    Optional[serve_stale_on_error] => Boolean,
    Optional[allow_authorized]     => Boolean,
    Optional[statfileslevel]       => Integer[0],
    Optional[invalidate]           => Array[Dispatcher::Farm::GlobRule],
    Optional[invalidate_handler]   => Stdlib::Absolutepath,
    Optional[ignore_url_params]    => Array[Dispatcher::Farm::GlobRule],
    Optional[headers]              => Array[String],
    Optional[mode]                 => Stdlib::Filemode,
    Optional[grace_period]         => Integer[0],
    Optional[enable_ttl]           => Boolean,
  }
]
