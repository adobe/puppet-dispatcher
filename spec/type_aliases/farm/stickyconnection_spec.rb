# frozen_string_literal: true

require 'spec_helper'

describe 'Dispatcher::Farm::StickyConnection' do
  describe 'Valid values' do
    [
      { paths: ['/products'] },
      { paths: ['/products'], domain: 'example.com' },
      { paths: ['/products'], http_only: true },
      { paths: ['/products'], http_only: false },
      { paths: ['/products'], secure: true },
      { paths: ['/products'], secure: false },
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'Invalid group resource values' do
    [
      {},
      { paths: {} },
      { paths: ['/products'], domain: false },
      { paths: ['/products'], http_only: nil },
      { paths: ['/products'], http_only: 'invalid' },
      { paths: ['/products'], secure: nil },
      { paths: ['/products'], secure: 'invalid' },
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
