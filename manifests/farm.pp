#
# Puppet Dispatcher Module - A module to manage AEM Dispatcher installations and configuration files.
#
# Copyright 2019 Adobe Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# @summary
#   Installs and configures an AEM Dispatcher farm instance on your system.
#
# This will configure an AEM Dispatcher Farm instance on the node. Farms require a minimum set of configuation details to properly function. These are the `renderers`, `filters`, and `cache`.
# The remainder of the paramers have provided, reasonable defaults.
#
# @example
#   dispatcher::farm { 'publish' :
#     renderers => [
#       { hostname => 'localhost', port => 4503 },
#     ],
#     filters => [
#       { allow => false,
#         rank  => 1,
#         url   => { regex => true, pattern => '.*' },
#       },
#     ],
#     cache => {
#       docroot => '/var/www/html',
#       rules => [
#         { rank => 1, glob => '*.html', allow => true },
#       ],
#       allowed_clients => [
#         { rank => 1, glob => '*', allow => false },
#         { rank => 2, glob => '127.0.0.1', allow => true },
#       ],
#     }
#   }
#
# @param renderers
#   Specifes an array of renderers that to which this Farm will dispatch requests. Used to create the */renders* directive. See the
#   `Dispatcher::Farm::Renderer` documentation for details on the parameter's structure.
#
# @param filters
#   Specifies an array of filters that will be applied to the incoming requests. Used to create the */filter* directive. See the
#   `Dispatcher::Farm::Filter` documentation for details on the parameter's structure.
#
# @param cache
#   Configures the */cache* directive for the farm. See the `Dispatcher::Farm::Cache` documentation for details on the parameter's structure.
#
# @param ensure
#   Specifies if the farm host is present or absent.
#
# @param priority
#   Defines the priority for this farm. The priority will impact the order the file farm is loaded by the dispatcher module, and therefore
#   has implications for host resolution and request processing. For more information see the Dispatcher farm documentation.
#
# @param virtualhosts
#   Specifies the list of virtual hosts for which this farm will process requests. Used to create the */virtualhosts*
#   directive. See the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/configuring/dispatcher-configuration.html#identifying-virtual-hosts-virtualhosts)
#   for more details.
#
# @param clientheaders
#   Specifies the list of headers which will be passed through. Used to create the */clientheaders* directive. See the
#   [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/configuring/dispatcher-configuration.html#specifying-the-http-headers-to-pass-through-clientheaders)
#   for more details.
#
# @param sessionmanagement
#   Configures the */sessionmanagement* directive for a farm, used for seecuring cache access. See the
#   `Dispatcher::Farm::SessionManagement` documentation for details on the parameter's structure.
#
# @param vanity_urls
#   Configures the */vanity_urls* directive for a farm. See the `Dispatcher::Farm::VanityUrls` documentation for
#   details on the parameter's structure.
#
# @param propagate_synd_post
#   Sets the flag for the */propagateSyndPost* directive. See the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/configuring/dispatcher-configuration.html#forwarding-syndication-requests-propagatesyndpost)
#   for more details.
#
# @param auth_checker
#   Configures the */auth_checker* directive for a farm. See the `Dispatcher::Farm::AuthChecker` documentation for
#   more details.
#
# @param statistics_categories
#   Configures the */statistics* directive for a farm. See the `Dispatcher::Farm::StatisticsCategory` documentation for
#   more details.
#
# @param sticky_connections
#   Configures either the */stickyConnectionsFor* or */stickyConnections* directive for a farm. See the
#   `Dispatcher::Farm::StickyConnection` documentation for more details.
#
# @param health_check
#   If specified, sets the */health_check* url for a farm. See the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/configuring/dispatcher-configuration.html#specifying-a-health-check-page)
#   for details on the directive's use.
#
# @param retry_delay
#   If specified, sets the */retryDelay* directive for a farm. See the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/configuring/dispatcher-configuration.html#specifying-the-page-retry-delay)
#   for details on the directive's use.
#
# @param number_of_retries
#   If specified, sets the */numberOfRetries* directive for a farm. See the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/configuring/dispatcher-configuration.html#configuring-the-number-of-retries)
#   for details on the directive's use.
#
# @param unavailable_penalty
#   If specified, sets the */unavailablePenalty* directive for a farm. See the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/configuring/dispatcher-configuration.html#reflecting-server-unavailability-in-dispatcher-statistics)
#   for details on the directive's use.
#
# @param failover
#   If specified, sets the */failover* directive for a farm. See the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/configuring/dispatcher-configuration.html#using-the-failover-mechanism)
#   for details on the directive's use.
#
# @param secure
#   If set to `true`, will enable a set of rules intended to secure this farm based on the the [Dispatcher Security Checklist](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/getting-started/security-checklist.html).
#
#   The following rules are applied when this flag is set.
#
#   This filter will defined and positioned first in the list, providing a default security filter:
#   ```
#     /0000 { /type "deny" /url '.*' }
#   ```
#
#   These filters will be appended to the end of the filter list. Any user-defined filters will have a lower rank, and
#   therefore will be listed before these. The intent of these filters is to protect the system from inadvernt access to
#   code, crawling, or systems which should be secure in production.
#   ```
#     /9993 { /type "deny" /url "/crx/*" }
#     /9994 { /type "deny" /url "/system/*" }
#     /9995 { /type "deny" /url "/apps/*" }
#     /9996 { /type "deny" /selectors '(feed|rss|pages|languages|blueprint|infinity|tidy|sysview|docview|query|[0-9-]+|jcr:content)' /extension '(json|xml|html|feed)' }
#     /9997 { /type "deny" /method "GET" /query "debug=*" }
#     /9998 { /type "deny" /method "GET" /query "wcmmode=*" }
#     /9999 { /type "deny" /extension "jsp" }
#   ```
#
#   A default deny rule for cache invalidation will be added; it is expected there will be additional user-defined value(s) for approved clients.
#   ```
#     /cache {
#       ...
#       /allowedClients {
#         /0000 { /type "deny" /glob "*" }
#       }
#     }
#   ```
#
define dispatcher::farm (
  Array[Dispatcher::Farm::Renderer] $renderers          = lookup("dispatcher::farm::${name}::renderers", Array[Dispatcher::Farm::Renderer], 'deep'),
  Array[Dispatcher::Farm::Filter] $filters              = lookup("dispatcher::farm::${name}::filters", Array[Dispatcher::Farm::Filter], 'deep'),
  Dispatcher::Farm::Cache $cache                        = lookup("dispatcher::farm::${name}::cache", Dispatcher::Farm::Cache, 'deep'),
  Enum['absent', 'present'] $ensure                     = lookup("dispatcher::farm::${name}::ensure", Enum['absent', 'present'], 'first', 'present'),
  Integer[0] $priority                                  = lookup("dispatcher::farm::${name}::priority", Integer[0], 'first', 0),
  Array[String] $virtualhosts                           = lookup("dispatcher::farm::${name}::virtualhosts", Array[String], 'deep', [$name]),
  Array[String] $clientheaders                          = lookup("dispatcher::farm::${name}::clientheaders", Array[String], 'deep', []),
  Optional[Dispatcher::Farm::SessionManagement]
      $sessionmanagement                                = lookup("dispatcher::farm::${name}::sessionmanagement", Optional[Dispatcher::Farm::SessionManagement], 'first', undef),
  Optional[Dispatcher::Farm::VanityUrls] $vanity_urls   = lookup("dispatcher::farm::${name}::vanity_urls", Optional[Dispatcher::Farm::VanityUrls], 'first', undef),
  Boolean $propagate_synd_post                          = lookup("dispatcher::farm::${name}::propagate_synd_post", Boolean, 'first', false),
  Optional[Dispatcher::Farm::AuthChecker] $auth_checker = lookup("dispatcher::farm::${name}::auth_checker", Optional[Dispatcher::Farm::AuthChecker], 'deep', undef),
  Optional[Array[Dispatcher::Farm::StatisticsCategory]]
      $statistics_categories                            = lookup("dispatcher::farm::${name}::statistics_categories", Optional[Array[Dispatcher::Farm::StatisticsCategory]], 'deep', undef),
  Optional[Dispatcher::Farm::StickyConnection]
      $sticky_connections                               = lookup("dispatcher::farm::${name}::sticky_connections", Optional[Dispatcher::Farm::StickyConnection], 'deep', undef),
  Optional[String[1]] $health_check                     = lookup("dispatcher::farm::${name}::health_check", Optional[String[1]], 'first', undef),
  Optional[Integer[0]] $retry_delay                     = lookup("dispatcher::farm::${name}::retry_delay", Optional[Integer[0]], 'first', undef),
  Optional[Integer[0]] $number_of_retries               = lookup("dispatcher::farm::${name}::number_of_retries", Optional[Integer[0]], 'first', undef),
  Optional[Integer[0]] $unavailable_penalty             = lookup("dispatcher::farm::${name}::unavailable_penalty", Optional[Integer[0]], 'first', undef),
  Boolean $failover                                     = lookup("dispatcher::farm::${name}::failover", Boolean, 'first', false),
  Boolean $secure                                       = lookup("dispatcher::farm::${name}::secure", Boolean, 'first', false),
) {
  # Check for Apache because it is used by parameter defaults
  if !defined(Class['apache']) {
    fail('You must include the Apache class before using any dispatcher class or resources.')
  }

  if $::osfamily == 'RedHat' or $::operatingsystem =~ /^[Aa]mazon$/ {
    $_farm_path = $::apache::mod_dir

  } elsif $::osfamily == 'Debian' {
    $_farm_path = $::apache::mod_enable_dir
  } else {
    fail("Class['dispatcher']: Unsupported osfamily: ${::osfamily}")
  }

  if $priority < 10 {
    $_priority = "0${priority}"
  }
  else {
    $_priority = $priority
  }

  if ($secure) {
    $_secure_cache = lookup('dispatcher::farm::cache::secured', Hash, 'deep', {})
    $_cache_tmp = {
      'allowed_clients' => $cache['allowed_clients'] + $_secure_cache['allowed_clients']
    }
    $_cache = deep_merge($cache, $_cache_tmp)

    $_secure_filters = lookup('dispatcher::farm::filters::secured', Array, 'deep', [])
    $_filters = $_secure_filters + $filters
  } else {
    $_cache = $cache
    $_filters = $filters
  }

  concat { "dispatcher.${_priority}-${name}.inc.any":
    ensure         => $ensure,
    path           => "${_farm_path}/dispatcher.${_priority}-${name}.inc.any",
    owner          => 'root',
    group          => $::apache::params::root_group,
    mode           => $::apache::params::file_mode,
    order          => 'numeric',
    ensure_newline => true,
    require        => Package['httpd'],
    notify         => Class['apache::service'],
  }

  concat::fragment { "${name}-farm-header":
    target  => "dispatcher.${_priority}-${name}.inc.any",
    order   => 0,
    content => template('dispatcher/farm/_file_header.erb')
  }

  if ($clientheaders.size > 0) {
    concat::fragment { "${name}-farm-clientheaders":
      target  => "dispatcher.${_priority}-${name}.inc.any",
      order   => 10,
      content => template('dispatcher/farm/_clientheaders.erb')
    }
  }

  concat::fragment { "${name}-farm-virtualhosts":
    target  => "dispatcher.${_priority}-${name}.inc.any",
    order   => 20,
    content => template('dispatcher/farm/_virtualhosts.erb')
  }

  if ($sessionmanagement) {
    concat::fragment { "${name}-farm-sessionmanagement":
      target  => "dispatcher.${_priority}-${name}.inc.any",
      order   => 30,
      content => template('dispatcher/farm/_sessionmanagement.erb')
    }
  }

  concat::fragment { "${name}-farm-renders":
    target  => "dispatcher.${_priority}-${name}.inc.any",
    order   => 40,
    content => template('dispatcher/farm/_renders.erb')
  }

  concat::fragment { "${name}-farm-filter":
    target  => "dispatcher.${_priority}-${name}.inc.any",
    order   => 50,
    content => template('dispatcher/farm/_filter.erb')
  }

  if ($vanity_urls) {
    concat::fragment { "${name}-farm-vanityurls":
      target  => "dispatcher.${_priority}-${name}.inc.any",
      order   => 60,
      content => template('dispatcher/farm/_vanityurls.erb')
    }
  }

  if ($propagate_synd_post) {
    concat::fragment { "${name}-farm-propagatesyndpost":
      target  => "dispatcher.${_priority}-${name}.inc.any",
      order   => 70,
      content => '  /propagateSyndPost "1"'
    }
  }

  concat::fragment { "${name}-farm-cache":
    target  => "dispatcher.${_priority}-${name}.inc.any",
    order   => 80,
    content => template('dispatcher/farm/_cache.erb')
  }

  if ($auth_checker) {
    concat::fragment { "${name}-farm-authchecker":
      target  => "dispatcher.${_priority}-${name}.inc.any",
      order   => 90,
      content => template('dispatcher/farm/_authchecker.erb')
    }
  }

  if ($statistics_categories) {
    concat::fragment { "${name}-farm-statisticscategories":
      target  => "dispatcher.${_priority}-${name}.inc.any",
      order   => 100,
      content => template('dispatcher/farm/_statisticscategories.erb')
    }
  }

  if ($sticky_connections) {
    concat::fragment { "${name}-farm-stickyconnections":
      target  => "dispatcher.${_priority}-${name}.inc.any",
      order   => 110,
      content => template('dispatcher/farm/_stickyconnections.erb')
    }
  }

  if ($health_check) {
    concat::fragment { "${name}-farm-healthcheck":
      target  => "dispatcher.${_priority}-${name}.inc.any",
      order   => 120,
      content => "  /health_check \"${health_check}\""
    }
  }

  if ($retry_delay) {
    concat::fragment { "${name}-farm-retrydelay":
      target  => "dispatcher.${_priority}-${name}.inc.any",
      order   => 130,
      content => "  /retryDelay \"${retry_delay}\""
    }
  }

  if ($number_of_retries) {
    concat::fragment { "${name}-farm-numberofretries":
      target  => "dispatcher.${_priority}-${name}.inc.any",
      order   => 140,
      content => "  /numberOfRetries \"${number_of_retries}\""
    }
  }

  if ($unavailable_penalty) {
    concat::fragment { "${name}-farm-unavailablepenalty":
      target  => "dispatcher.${_priority}-${name}.inc.any",
      order   => 150,
      content => "  /unavailablePenalty \"${unavailable_penalty}\""
    }
  }

  if ($failover) {
    concat::fragment { "${name}-farm-failover":
      target  => "dispatcher.${_priority}-${name}.inc.any",
      order   => 160,
      content => '  /failover "1"'
    }
  }

  concat::fragment { "${name}-farm-footer":
    target  => "dispatcher.${_priority}-${name}.inc.any",
    order   => 999,
    content => '}'
  }

}
