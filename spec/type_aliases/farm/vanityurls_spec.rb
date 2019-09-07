# frozen_string_literal: true

require 'spec_helper'

describe 'Dispatcher::Farm::VanityUrls' do
  describe 'Valid values' do
    [
      { file: '/full/path/to/file', delay: 300 },
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'Invalid group resource values' do
    [
      {},
      { file: 'not/fully/qualified' },
      { file: 'not/fully/qualified', delay: 600 },
      { file: 'not/fully/qualified', delay: 600 },
      { file: 'file-only', delay: 600 },
      { file: false, delay: 600 },
      { delay: 600 },
      { file: '/fully/qualfied/file', delay: -100 },
      { file: '/fully/qualfied/file', delay: true },
      { file: 'not/fully/qualfied', delay: 'invalid' },
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
