# frozen_string_literal: true

require 'spec_helper'

describe 'Dispatcher::Farm::Filter' do
  describe 'Valid values' do
    [
      { allow: true, rank: 0 },
      { allow: true, rank: 10, method: { regex: true, pattern: 'GET' } },
      { allow: true, rank: 10, url: { regex: true, pattern: '*.html' } },
      { allow: true, rank: 10, query: { regex: true, pattern: 'param=value' } },
      { allow: true, rank: 10, protocol: { regex: true, pattern: 'http' } },
      { allow: true, rank: 10, path: { regex: true, pattern: '/content/test/en' } },
      { allow: true, rank: 10, selectors: { regex: true, pattern: '(feed|rss|pages|languages|blueprint|infinity|tidy)' } },
      { allow: true, rank: 10, extension: { regex: true, pattern: '(css|gif|ico|js|png|swf|jpe?g)' } },
      { allow: true, rank: 10, suffix: { regex: true, pattern: '/path/to/suffix' } },
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'Invalid group resource values' do
    [
      {},
      { allow: nil },
      { allow: 'invalid' },
      { allow: true, rank: nil },
      { allow: true, rank: -1 },
      { allow: true, rank: 10, method: nil },
      { allow: true, rank: 10, url: nil },
      { allow: true, rank: 10, query: nil },
      { allow: true, rank: 10, protocol: nil },
      { allow: true, rank: 10, path: nil },
      { allow: true, rank: 10, selectors: nil },
      { allow: true, rank: 10, extension: nil },
      { allow: true, rank: 10, suffix: nil },
      { allow: true, rank: 10, method: {} },
      { allow: true, rank: 10, url: {} },
      { allow: true, rank: 10, query: {} },
      { allow: true, rank: 10, protocol: {} },
      { allow: true, rank: 10, path: {} },
      { allow: true, rank: 10, selectors: {} },
      { allow: true, rank: 10, extension: {} },
      { allow: true, rank: 10, suffix: {} },
      { allow: true, rank: 10, method: [] },
      { allow: true, rank: 10, url: [] },
      { allow: true, rank: 10, query: [] },
      { allow: true, rank: 10, protocol: [] },
      { allow: true, rank: 10, path: [] },
      { allow: true, rank: 10, selectors: [] },
      { allow: true, rank: 10, extension: [] },
      { allow: true, rank: 10, suffix: [] },
      { allow: true, rank: 10, method: 'string' },
      { allow: true, rank: 10, url: 'string' },
      { allow: true, rank: 10, query: 'string' },
      { allow: true, rank: 10, protocol: 'string' },
      { allow: true, rank: 10, path: 'string' },
      { allow: true, rank: 10, selectors: 'string' },
      { allow: true, rank: 10, extension: 'string' },
      { allow: true, rank: 10, suffix: 'string' },
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
