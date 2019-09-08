# Cache attributes hash.
# @summary A hash of cache attributes.
#   Used to configure the `/cache` parameter instance of a Farm.
#
type Dispatcher::Farm::Cache = Struct[
  {
    docroot              => Stdlib::Absolutepath,
    rules                => Array[Dispatcher::Farm::GlobRule],
    allowed_clients      => Array[Dispatcher::Farm::GlobRule],
    statfile             => Optional[Stdlib::Absolutepath],
    serve_stale_on_error => Optional[Boolean],
    allow_authorized     => Optional[Boolean],
    statfileslevel       => Optional[Integer[0]],
    invalidate           => Optional[Array[Dispatcher::Farm::GlobRule]],
    invalidate_handler   => Optional[Stdlib::Absolutepath],
    ignore_url_params    => Optional[Array[Dispatcher::Farm::GlobRule]],
    headers              => Optional[Array[String]],
    mode                 => Optional[Stdlib::Filemode],
    grace_period         => Optional[Integer[0]],
    enable_ttl           => Optional[Boolean],
  }
]
