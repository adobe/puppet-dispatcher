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

describe 'Dispatcher::Farm::SessionManagement' do
  describe 'Valid values' do
    [
      { directory: '/path/to/sessions' },
      { directory: '/path/to/sessions', encode: 'md5' },
      { directory: '/path/to/sessions', header: 'Cookie:name-of-cookie' },
      { directory: '/path/to/sessions', timeout: 1000 },
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'Invalid group resource values' do
    [
      {},
      { directory: 'not/fully/qualified' },
      { directory: '/path/to/sessions', encode: 123 },
      { directory: '/path/to/sessions', header: 123 },
      { directory: '/path/to/sessions', timeout: nil },
      { directory: '/path/to/sessions', timeout: -1 },
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
