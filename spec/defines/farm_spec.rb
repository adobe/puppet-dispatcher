# frozen_string_literal: true

require 'spec_helper'

describe 'dispatcher::farm', type: :define do
  let(:hiera_config) { 'spec/hiera.yaml' }
  let(:title) { 'namevar' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'requires Apache' do
        let(:pre_condition) { '' }

        it { is_expected.to raise_error(%r{You must include the Apache class}) }
      end

      describe 'parameter validation' do
        context 'setting manually' do
          context 'renderers' do
            let(:params) { { renderers: {}, filters: { allow: true, url: { regex: true, pattern: '.*' } } } }

            it { is_expected.to raise_error(%r{'renderers' expects an Array}) }
          end
          context 'filters' do
            let(:params) { { renders: { hostname: 'localhost', port: 4503 }, filters: {} } }

            it { is_expected.to raise_error(%r{'filters' expects an Array}) }
          end
          context 'ensure' do
            let(:params) { { ensure: 'invalid' } }

            it { is_expected.to raise_error(%r{'ensure' expects a match for Enum\['absent', 'present'\]}) }
          end
          context 'priority' do
            let(:params) { { priority: -1 } }

            it { is_expected.to raise_error(%r{'priority' expects an Integer\[0\]}) }
          end
          context 'virtualhosts' do
            let(:params) { { virtualhosts: { 'key' => 'value' } } }

            it { is_expected.to raise_error(%r{'virtualhosts' expects an Array}) }
          end
          context 'clientheaders' do
            let(:params) { { clientheaders: { 'key' => 'value' } } }

            it { is_expected.to raise_error(%r{'clientheaders' expects an Array}) }
          end
          context 'sessionmanagement' do
            let(:params) { { sessionmanagement: [] } }

            it { is_expected.to raise_error(%r{'sessionmanagement' expects a Dispatcher::Farm::SessionManagement}) }
          end
          context 'vanityurls' do
            let(:params) { { vanityurls: [] } }

            it { is_expected.to raise_error(%r{'vanityurls' expects a Dispatcher::Farm::VanityUrl}) }
          end
        end
        context 'hiera invalid' do
          context 'renderers' do
            let(:facts) { os_facts.merge(testname: 'invalid-renderers') }

            it { is_expected.to raise_error(%r{expects an Array}) }
          end
          context 'filters' do
            let(:facts) { os_facts.merge(testname: 'invalid-filters') }

            it { is_expected.to raise_error(%r{expects an Array}) }
          end
          context 'ensure' do
            let(:facts) { os_facts.merge(testname: 'invalid-ensure') }

            it { is_expected.to raise_error(%r{expects a match for Enum\['absent', 'present'\]}) }
          end
          context 'priority' do
            let(:facts) { os_facts.merge(testname: 'invalid-priority') }

            it { is_expected.to raise_error(%r{expects an Integer\[0\]}) }
          end
          context 'virtualhosts' do
            let(:facts) { os_facts.merge(testname: 'invalid-virtualhosts') }

            it { is_expected.to raise_error(%r{expects an Array}) }
          end
          context 'clientheaders' do
            let(:facts) { os_facts.merge(testname: 'invalid-clientheaders') }

            it { is_expected.to raise_error(%r{expects an Array}) }
          end
          context 'sessionmanagement' do
            let(:facts) { os_facts.merge(testname: 'invalid-sessionmanagement') }

            it { is_expected.to raise_error(%r{expects a Dispatcher::Farm::SessionManagement}) }
          end
          context 'vanityurls' do
            let(:facts) { os_facts.merge(testname: 'invalid-vanityurls') }

            it { is_expected.to raise_error(%r{expects a Dispatcher::Farm::VanityUrls}) }
          end
        end
      end
    end
  end
end
