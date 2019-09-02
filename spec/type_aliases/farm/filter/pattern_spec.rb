# frozen_string_literal: true

require 'spec_helper'

describe 'Dispatcher::Farm::Filter::Pattern' do
  describe 'Valid values' do
    [
      { regex: true, pattern: 'pattern' },
      { regex: false, pattern: 'pattern' },
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'Invalid group resource values' do
    [
      { regex: 'invalid', pattern: 'pattern' },
      { regex: true, pattern: false },
      { regex: true, pattern: [] },
      { regex: true, pattern: {} },
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
