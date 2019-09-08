# frozen_string_literal: true

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
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        statfile:        '/path/to/statfile',
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        serve_stale_on_error:      true,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        serve_stale_on_error:      false,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
        allow_authorized: true,
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
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
        docroot:         'invalid',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        statfile:        'invalid',
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        serve_stale_on_error:      'invalid',
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      {
        docroot:         '/path/to/docroot',
        rules:           [{ rank: 1, glob: '*.html', allow: true }],
        allow_authorized: 'invalid',
        allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }],
      },
      { docroot: '/path/to/docroot', allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }] },
      { docroot: '/path/to/docroot', rules: {}, allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }] },
      { docroot: '/path/to/docroot', rules: ['invalid'], allowed_clients: [{ rank: 1, glob: '*.*.*.*', allow: false }] },
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
        enable_ttl:      'invalid',
      },
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
