# frozen_string_literal: true

require 'spec_helper'

describe 'Dispatcher::Farm::AuthChecker' do
  describe 'Valid values' do
    [
      {
        url:     '/path/to/auth/checker',
        filters: [{ rank: 1, glob: '/content/secure/*.html', allow: true }],
        headers: [{ rank: 1, glob: 'Set-Cookie:*', allow: true }],
      },
      {
        url:     '/path/to/auth/checker',
        filters: [{ rank: 1, glob: '*', allow: false }, { rank: 10, glob: '/content/secure/*.html', allow: true }],
        headers: [{ rank: 1, glob: '*', allow: false }, { rank: 10, glob: 'Set-Cookie:*', allow: true }],
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
        filters: [{ rank: 1, glob: '/content/secure/*.html', allow: true }],
        headers: [{ rank: 1, glob: 'Set-Cookie:*', allow: true }],
      },
      {
        url:     '/path/to/auth/checker',
        headers: [{ rank: 1, glob: 'Set-Cookie:*', allow: true }],
      },
      {
        url:     '/path/to/auth/checker',
        filters: {},
        headers: [{ rank: 1, glob: 'Set-Cookie:*', allow: true }],
      },
      {
        url:     '/path/to/auth/checker',
        filters: [{ rank: 1, glob: '/content/secure/*.html', allow: true }],
      },
      {
        url:     '/path/to/auth/checker',
        filters: [{ rank: 1, glob: '/content/secure/*.html', allow: true }],
        headers: {},
      },
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
