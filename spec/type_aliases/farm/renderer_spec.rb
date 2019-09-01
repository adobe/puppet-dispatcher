# frozen_string_literal: true

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
      { hostname: '$', port: 4502 },
      { hostname: '_', port: 4502 },
      { hostname: 'www www.example.com', port: 4502 },
      { hostname: 'bob@example.com', port: 4502 },
      { hostname: '%.example.com', port: 4502 },
      { hostname: '2001:0d8', port: 4502 },
      { hostname: 'localhost', port: -1 },
      { hostname: 'localhost', port: 99_999 },
      { hostname: 'localhost', port: 4502, timeout: -1 },
      { hostname: 'localhost', port: 4502, receive_timeout: -1 },
      { hostname: 'localhost', port: 4502, ipv4: 'invalid' },
      { hostname: 'localhost', port: 4502, secure: 'invalid' },
      { hostname: 'localhost', port: 4502, always_resolve: 'invalids' },
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
