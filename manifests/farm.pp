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

# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   dispatcher::farm { 'namevar': }
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
  Optional[Dispatcher::Farm::VanityUrls]$vanity_urls    = lookup("dispatcher::farm::${name}::vanity_urls", Optional[Dispatcher::Farm::VanityUrls], 'first', undef),
  Boolean $propagate_synd_post                          = lookup("dispatcher::farm::${name}::propagate_synd_post", Boolean, 'first', false),
  Optional[Dispatcher::Farm::AuthChecker] $auth_checker = lookup("dispatcher::farm::${name}::auth_checker", Optional[Dispatcher::Farm::AuthChecker], 'deep', undef),
  Optional[Array[Dispatcher::Farm::StatisticsCategory]]
      $statistics_categories                            = lookup("dispatcher::farm::${name}::statistics_categories", Optional[Array[Dispatcher::Farm::StatisticsCategory]], 'deep', undef),
  Optional[Variant[String[1], Dispatcher::Farm::StickyConnection]]
      $sticky_connections                               = lookup("dispatcher::farm::${name}::sticky_connections", Optional[Variant[String[1], Dispatcher::Farm::StickyConnection]], 'deep', undef),
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
    ensure  => $ensure,
    path    => "${::apache::vhost_dir}/dispatcher.${_priority}-${name}.inc.any",
    owner   => 'root',
    group   => $::apache::params::root_group,
    mode    => $::apache::params::file_mode,
    order   => 'numeric',
    require => Package['httpd'],
    notify  => Class['apache::service'],
  }

  concat::fragment { "${name}-farm-header":
    target  => "dispatcher.${_priority}-${name}.inc.any",
    order   => 0,
    content => template('dispatcher/farm/_file_header.erb')
  }

  concat::fragment { "${name}-farm-clientheaders":
    target  => "dispatcher.${_priority}-${name}.inc.any",
    order   => 10,
    content => template('dispatcher/farm/_clientheaders.erb')
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
      content => '  /health_check "/path/to/health/check.html"'
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
