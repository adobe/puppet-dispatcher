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

describe 'Dispatcher::Farm::Cache' do
  describe 'Valid values' do
    [
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }, { rank: 20, glob: '127.0.0.1', allow: true }],
      },
      {
        docroot:              '/path/to/docroot',
        rules:                [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients:      [{ rank: 1, glob: '*.*.*.*', allow: false }],
        manage_docroot:       true,
      },
      {
        docroot:              '/path/to/docroot',
        rules:                [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients:      [{ rank: 1, glob: '*.*.*.*', allow: false }],
        manage_docroot:       false,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        statfile:        '/path/to/statfile',
      },
      {
        docroot:              '/path/to/docroot',
        rules:                [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients:      [{ rank: 1, glob: '*.*.*.*', allow: false }],
        serve_stale_on_error: true,
      },
      {
        docroot:              '/path/to/docroot',
        rules:                [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients:      [{ rank: 1, glob: '*.*.*.*', allow: false }],
        serve_stale_on_error: false,
      },
      {
        docroot:          '/path/to/docroot',
        rules:            [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients:  [{ rank: 1, glob: '*.*.*.*', allow: false }],
        allow_authorized: true,
      },
      {
        docroot:          '/path/to/docroot',
        rules:            [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients:  [{ rank: 1, glob: '*.*.*.*', allow: false }],
        allow_authorized: false,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }, { rank: 10, glob: '*.css', allow: false }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        statfileslevel:  1,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        invalidate:      [{ rank: 1, glob: '*.html', allow: true }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        invalidate:      [{ rank: 1, glob: '*.html', allow: true }, { rank: 10, glob: '*.css', allow: false }],
      },
      {
        docroot:            '/path/to/docroot',
        rules:              [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients:    [{ rank: 1, glob: '*.*.*.*', allow: false }],
        invalidate_handler: '/path/to/invalidate/handler',
      },
      {
        docroot:           '/path/to/docroot',
        rules:             [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients:   [{ rank: 1, glob: '*.*.*.*', allow: false }],
        ignore_url_params: [{ rank: 1, glob: 'a=b', allow: true }],
      },
      {
        docroot:           '/path/to/docroot',
        rules:             [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients:   [{ rank: 1, glob: '*.*.*.*', allow: false }],
        ignore_url_params: [{ rank: 1, glob: '*', allow: false }, { rank: 10, glob: 'a=b', allow: true }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        headers:         ['Cache-Control'],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        mode:            '0640',
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        mode:            'a=Xr,g=w',
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        grace_period:    4,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        enable_ttl:      true,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        enable_ttl:      false,
      },
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'Invalid group resource values' do
    [
      {},
      {
        docroot:         nil,
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:         'invalid',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:              '/path/to/docroot',
        rules:                [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients:      [{ rank: 1, glob: '*.*.*.*', allow: false }],
        manage_docroot:       'invalid',
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        statfile:        nil,
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        statfile:        'invalid',
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:              '/path/to/docroot',
        rules:                [{ rank: 1, glob: '*.html', allow: true }],
        serve_stale_on_error: nil,
        allowed_clients:      [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:              '/path/to/docroot',
        rules:                [{ rank: 1, glob: '*.html', allow: true }],
        serve_stale_on_error: 'invalid',
        allowed_clients:      [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:          '/path/to/docroot',
        rules:            [{ rank: 1, glob: '*.html', allow: true }],
        allow_authorized: nil,
        allowed_clients:  [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:          '/path/to/docroot',
        rules:            [{ rank: 1, glob: '*.html', allow: true }],
        allow_authorized: 'invalid',
        allowed_clients:  [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      { docroot: '/path/to/docroot', allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }] },
      { docroot: '/path/to/docroot', rules: nil, allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }] },
      { docroot: '/path/to/docroot', rules: {}, allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }] },
      { docroot: '/path/to/docroot', rules: ['invalid'], allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }] },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        statfileslevel:  nil,
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        statfileslevel:  -1,
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        statfileslevel:  'invalid',
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        invalidate:      nil,
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        invalidate:      {},
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        invalidate:      ['invalid'],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:            '/path/to/docroot',
        rules:              [{ rank: 1, glob: '*.html', allow: true }],
        invalidate_handler: nil,
        allowed_clients:    [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:            '/path/to/docroot',
        rules:              [{ rank: 1, glob: '*.html', allow: true }],
        invalidate_handler: 10,
        allowed_clients:    [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:            '/path/to/docroot',
        rules:              [{ rank: 1, glob: '*.html', allow: true }],
        invalidate_handler: false,
        allowed_clients:    [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot: '/path/to/docroot',
        rules:   [{ rank: 1, glob: '*.html', allow: true }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: nil,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: {},
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: ['invalid'],
      },
      {
        docroot:           '/path/to/docroot',
        rules:             [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients:   [{ rank: 1, glob: '*.*.*.*', allow: false }],
        ignore_url_params: nil,
      },
      {
        docroot:           '/path/to/docroot',
        rules:             [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients:   [{ rank: 1, glob: '*.*.*.*', allow: false }],
        ignore_url_params: {},
      },
      {
        docroot:           '/path/to/docroot',
        rules:             [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients:   [{ rank: 1, glob: '*.*.*.*', allow: false }],
        ignore_url_params: ['invalid'],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        headers:         nil,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        headers:         {},
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        headers:         'invalid',
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        mode:            nil,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        mode:            640,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        mode:            '21240',
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        mode:            'invalid',
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        grace_period:    nil,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        grace_period:    'invalid',
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        grace_period:    -1,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        grace_period:    nil,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        grace_period:    'invalid',
      },
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
