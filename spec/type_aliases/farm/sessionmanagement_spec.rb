# frozen_string_literal: true

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
      { directory: '/path/to/sessions', timeout: -1 },
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
