# frozen_string_literal: true

require 'spec_helper'

describe 'Dispatcher::Farm::StatisticsCategory' do
  describe 'Valid values' do
    [
      { rank: 1, name: 'html', glob: '*.html' },
      { rank: 1, name: 'others', glob: '*' },
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'Invalid group resource values' do
    [
      {},
      { name: 'html', glob: '*.html' },
      { rank: 1, glob: '*.html' },
      { rank: 1, name: 'html' },
      { rank: 'invalid', name: 'html', glob: '*.html' },
      { rank: 1, name: false, glob: '*' },
      { rank: 1, name: 'others', glob: false },
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
