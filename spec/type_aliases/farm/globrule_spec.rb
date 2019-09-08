# frozen_string_literal: true

require 'spec_helper'

describe 'Dispatcher::Farm::GlobRule' do
  describe 'Valid values' do
    [
      { rank: 10, glob: '*.html', allow: true },
      { rank: 1, glob: '*.html', allow: false },
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'Invalid group resource values' do
    [
      {},
      { glob: '*.html', allow: true },
      { rank: -1, glob: '*.html', allow: true },
      { rank: 10, allow: true },
      { rank: 10, glob: true, allow: false },
      { rank: 10, glob: '*.html' },
      { rank: 10, glob: '*.html', allow: 'invalid' },
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
