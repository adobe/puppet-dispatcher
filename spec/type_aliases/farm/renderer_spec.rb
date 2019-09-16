# frozen_string_literal: true

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

require 'spec_helper'

describe 'Dispatcher::Farm::Renderer' do
  describe 'Valid values' do
    [
      { hostname: 'localhost', port: 4502 },
      { hostname: 'www.example.com', port: 4502 },
      { hostname: '127.0.0.1', port: 4502 },
      { hostname: 'localhost', port: 4502, timeout: 100 },
      { hostname: 'localhost', port: 4502, receive_timeout: 100_000 },
      { hostname: 'localhost', port: 4502, ipv4: true },
      { hostname: 'localhost', port: 4502, ipv4: false },
      { hostname: 'localhost', port: 4502, secure: true },
      { hostname: 'localhost', port: 4502, secure: false },
      { hostname: 'localhost', port: 4502, always_resolve: true },
      { hostname: 'localhost', port: 4502, always_resolve: false },
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'Invalid group resource values' do
    [
      {},
      { port: 4502 },
      { hostname: '$', port: 4502 },
      { hostname: '_', port: 4502 },
      { hostname: 'www www.example.com', port: 4502 },
      { hostname: 'bob@example.com', port: 4502 },
      { hostname: '%.example.com', port: 4502 },
      { hostname: '2001:0d8', port: 4502 },
      { hostname: 'localhost', port: nil },
      { hostname: 'localhost', port: -1 },
      { hostname: 'localhost', port: 99_999 },
      { hostname: 'localhost', port: 4502, timeout: nil },
      { hostname: 'localhost', port: 4502, timeout: -1 },
      { hostname: 'localhost', port: 4502, receive_timeout: nil },
      { hostname: 'localhost', port: 4502, receive_timeout: -1 },
      { hostname: 'localhost', port: 4502, ipv4: nil },
      { hostname: 'localhost', port: 4502, ipv4: 'invalid' },
      { hostname: 'localhost', port: 4502, secure: nil },
      { hostname: 'localhost', port: 4502, secure: 'invalid' },
      { hostname: 'localhost', port: 4502, always_resolve: nil },
      { hostname: 'localhost', port: 4502, always_resolve: 'invalid' },
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
