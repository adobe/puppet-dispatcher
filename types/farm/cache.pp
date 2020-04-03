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

#
# @summary A hash of cache attributes.
#   Used to configure the `/cache` parameter instance of a Farm.
#
# The Cache attributes structure. This type is passed to a `dispatcher::farm` to confgure the *cache* parameter. This will define the properties as specified in the Dispatcher documentation for [caching content](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/configuring/dispatcher-configuration.html#configuring-the-dispatcher-cache-cache).
#
# Parameters:
#  - docroot:               `StdLib::Absolutepath`
#  - rules:                 `Array[Dispatcher::Farm::GlobRule]`
#  - allowed_clients:       `Array[Dispatcher::Farm::GlobRule]`
#  - statfile               `Stdlib::Absolutepath`
#  - serve_stale_on_error:  `Boolean`
#  - allow_authorized       `Boolean`
#  - statfileslevel         `Integer[0]`
#  - invalidate             `Array[Dispatcher::Farm::GlobRule]`
#  - invalidate_handler     `Stdlib::Absolutepath`
#  - ignore_url_params      `Array[Dispatcher::Farm::GlobRule`
#  - headers                `Array[String]`
#  - mode                   `Stdlib::Filemode`
#  - grace_period           `Integer[0]`
#  - enable_ttl             `Boolean`
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
