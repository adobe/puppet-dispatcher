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
# @summary A hash of renderer attributes.
#   Used to configure the `/renderer` parameter instance of a Farm.
#
# The Renderer attributes structure. This type is passed to a `dispatcher::farm` to confgure the *renders* parameter. This will define the properties as specified in the Dispatcher documentation for [defining page renderers](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/configuring/dispatcher-configuration.html#defining-page-renderers-renders).
#
# Parameters:
#  - hostname:        `Stdlib::Host:`
#  - port:            `Stdlib::Port:`
#  - timeout:         `Integer[0]:`
#  - receive_timeout: `Integer[0]:`
#  - ipv4:            `Boolean:`
#  - secure:          `Boolean:`
#  - always_resolve:  `Boolean:`
#
type Dispatcher::Farm::Renderer = Struct[
  {
    hostname                  => Stdlib::Host,
    port                      => Stdlib::Port,
    Optional[timeout]         => Integer[0],
    Optional[receive_timeout] => Integer[0],
    Optional[ipv4]            => Boolean,
    Optional[secure]          => Boolean,
    Optional[always_resolve]  => Boolean,
  }
]
