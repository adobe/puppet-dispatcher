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
#   Installs and sets up the AEM Dispatcher module on your system.
#
# When this class is declared with the default options, Puppet:
# - Installs the specified dispatcher module into Apache modules directory
# - Defines a Puppet apache module resource for the dispatcher.
# - Defines a default set of Dispatcher configurations
# - Loads all defined dispatcher farms
# - Reloads the Apache service
#
# @example
#   class { 'dispatcher' :
#     module_file => '/path/to/module/file.so'
#   }
#   contain dispatcher
#
# @param module_file
#   Specifes the source location of the dispatcher module. This is the file that will be copied into the Apache module library path.
#
# @param decline_root
#   Sets the value for `DispatcherDeclineRoot`. Defaults to `true`. For details see the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/getting-started/dispatcher-install.html#apache-web-server-configure-apache-web-server-for-dispatcher).
#
# @param log_file
#   Sets the value for `DispatcherLog`. Defaults to `<Apache logroot>/dispatcher.log`. For details see the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/getting-started/dispatcher-install.html#apache-web-server-configure-apache-web-server-for-dispatcher).
#
# @param log_level
#   Sets the value for `DispatcherLogLevel`. Defaults to `warn`. For details see the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/getting-started/dispatcher-install.html#apache-web-server-configure-apache-web-server-for-dispatcher).
#
# @param pass_error
#   Sets the value for `DispatcherPassError`. Defaults to `false`. For details see the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/getting-started/dispatcher-install.html#apache-web-server-configure-apache-web-server-for-dispatcher).
#
# @param use_processed_url
#   Sets the value for `DispatcherUseProcessedURL`. Defaults to `true`. For details see the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/getting-started/dispatcher-install.html#apache-web-server-configure-apache-web-server-for-dispatcher).
#
# @param farms
#   A list of Dispatcher Farm names. If specified a `dispatcher::farm` defintion will be created for each name. Use hiera data to specify the remaining parameters.<br/>
#   For example, to configure a Dispatcher with two farms *author* and *publish*:
#   ```puppet
#   class { 'dispatcher' :
#     module_file => '/path/to/module/file.so',
#     farms       => ['author', 'publish'],
#   }
#   contain dispatcher
#   ```
#
# @param keep_alive_timeout
#   If specified, sets the value for `DispatcherKeepAliveTimeout`. Default For details see the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/getting-started/dispatcher-install.html#apache-web-server-configure-apache-web-server-for-dispatcher).
#
# @param no_cannon_url
#   If specified, sets the value for `DispatcherNoCanonURL`. For details see the [Dispatcher documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/getting-started/dispatcher-install.html#apache-web-server-configure-apache-web-server-for-dispatcher).
#
class dispatcher (
  Stdlib::Filesource $module_file,
  Boolean $decline_root,
  Stdlib::Absolutepath $log_file,
  Enum['error', 'warn', 'info', 'debug', 'trace'] $log_level,
  Variant[Boolean, Pattern[/^[\d\-,]+$/]] $pass_error,
  Boolean $use_processed_url,
  Array[String] $farms                     = [],
  Optional[Integer[0]] $keep_alive_timeout = undef,
  Optional[Boolean] $no_cannon_url         = undef,
) {

  # Check for Apache because it is used by parameter defaults
  if !defined(Class['apache']) {
    fail('You must include the Apache class before using any dispatcher class or resources.')
  }

  if $::osfamily == 'RedHat' or $::operatingsystem =~ /^[Aa]mazon$/ {
    $_mod_path = "${::apache::httpd_dir}/${::apache::lib_path}"
    $_farm_path = $::apache::mod_dir
  } elsif $::osfamily == 'Debian' {
    $_mod_path = $::apache::lib_path
    $_farm_path = $::apache::mod_enable_dir
  } else {
    fail("Class['dispatcher']: Unsupported osfamily: ${::osfamily}")
  }
  $_filename = basename($module_file)

  $_owner = 'root'

  apache::mod { 'dispatcher':
    lib => 'mod_dispatcher.so',
  }

  file { "${_mod_path}/${_filename}":
    ensure  => file,
    owner   => $_owner,
    group   => $::apache::params::root_group,
    source  => $module_file,
    require => Package['httpd'],
    notify  => Class['Apache::Service'],
  }

  file { "${_mod_path}/mod_dispatcher.so":
    ensure  => link,
    owner   => $_owner,
    group   => $::apache::params::root_group,
    target  => "${_mod_path}/${_filename}",
    require => Package['httpd'],
    notify  => Class['Apache::Service'],
  }

  if $facts['selinux_enforced'] {
    File["${_mod_path}/${_filename}"] {
      seltype => 'httpd_modules_t',
    }

    File["${_mod_path}/mod_dispatcher.so"] {
      seltype => 'httpd_modules_t',
    }

    ensure_resource('selboolean', 'httpd_can_network_connect', { value => 'on', persistent => true })
  }

  file { "${_farm_path}/dispatcher.conf":
    ensure  => file,
    owner   => $_owner,
    group   => $::apache::params::root_group,
    content => template("${module_name}/dispatcher.conf.erb"),
    require => Package['httpd'],
    notify  => Class['Apache::Service'],
  }

  file { "${_farm_path}/dispatcher.farms.any":
    ensure  => file,
    owner   => $_owner,
    group   => $::apache::params::root_group,
    source  => 'puppet:///modules/dispatcher/dispatcher.farms.any',
    require => Package['httpd'],
    notify  => Class['Apache::Service'],
  }

  $farms.each |$farm| {
    ensure_resource('dispatcher::farm', $farm, { 'ensure' => 'present' })
  }

}
