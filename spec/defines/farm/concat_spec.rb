# frozen_string_literal: true

require 'spec_helper'

describe 'dispatcher::farm', type: :define do
  let(:hiera_config) { 'spec/hiera.yaml' }
  let(:title) { 'namevar' }
  let(:pre_condition) do
    <<~PUPPETFILE
      class { 'apache' : }
      class { 'dispatcher' :
        module_file => '/path/tot/module/file.so'
      }
    PUPPETFILE
  end
  let(:default_params) { {} }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { default_params }
      let(:vhost_dir) { catalogue.resource('Class[apache]').parameters[:vhost_dir] }
      let(:file_mode) { catalogue.resource('Class[apache]').parameters[:file_mode] }

      describe 'default parameters' do
        it { is_expected.to compile.with_all_deps }
        it do
          is_expected.to contain_dispatcher__farm('namevar').only_with(
            renderers:           [{ 'hostname' => 'localhost', 'port' => 4503 }],
            filters:             [{ 'allow' => false, 'rank' => 1, 'url' => { 'regex' => true, 'pattern' => '.*' } }],
            cache:               {
              'docroot'         => '/path/to/docroot',
              'rules'           => [{ 'rank' => 1, 'glob' => '*.html', 'allow' => true }],
              'allowed_clients' => [{ 'rank' => 1, 'glob' => '*.*.*.*', 'allow' => false }],
            },
            ensure:              'present',
            priority:            0,
            virtualhosts:        %w[namevar],
            clientheaders:       [],
            propagate_synd_post: false,
          )
        end
        it do
          is_expected.to contain_concat('dispatcher.00-namevar.inc.any').with(
            ensure: 'present',
            path:   "#{vhost_dir}/dispatcher.00-namevar.inc.any",
            owner:  'root',
            group:  'root',
            mode:   file_mode,
            order:  'numeric',
          ).that_requires('Package[httpd]').that_notifies('Class[apache::service]')
        end

      end

      context 'custom parameters' do
        let(:facts) { os_facts.merge(testname: 'customparams') }
        let(:title) { 'customparams' }

        it do
          is_expected.to contain_dispatcher__farm('customparams').only_with(
            renderers:           [{ 'hostname' => 'localhost', 'port' => 4503 }],
            filters:             [{ 'allow' => false, 'rank' => 10, 'method' => { 'regex' => false, 'pattern' => 'POST' } }],
            cache:               {
              'docroot'              => '/different/path/to/docroot',
              'rules'                => [{ 'rank' => 1, 'glob' => '*.html', 'allow' => true }, { 'rank' => 10, 'glob' => '*.js', 'allow' => false }],
              'allowed_clients'      => [{ 'rank' => 1, 'glob' => '*.*.*.*', 'allow' => false }, { 'rank' => 10, 'glob' => '127.0.0.1', 'allow' => true }],
              'statfile'             => '/path/to/statfile',
              'serve_stale_on_error' => true,
              'allow_authorized'     => true,
              'statfileslevel'       => 3,
              'invalidate'           => [{ 'rank' => 1, 'glob' => '*.html', 'allow' => false }, { 'rank' => 10, 'glob' => '*.jpg', 'allow' => true }],
              'invalidate_handler'   => '/opt/dispatcher/scripts/invalidate.sh',
              'ignore_url_params'    => [{ 'rank' => 1, 'glob' => '*', 'allow' => false }, { 'rank' => 10, 'glob' => 'q', 'allow' => true }],
              'headers'              => %w[Content-Type Cache-Control],
              'mode'                 => '0660',
              'grace_period'         => 10,
              'enable_ttl'           => true,
            },
            ensure:              'present',
            priority:            50,
            virtualhosts:        %w[www.example.com another.example.com],
            clientheaders:       %w[A-Client-Header Another-Client-Header],
            sessionmanagement:   {
              'directory' => '/path/to/sessions',
              'encode'    => 'sha1',
              'header'    => 'HTTP:authorization',
              'timeout'   => 90,
            },
            vanityurls:          { 'file' => '/path/to/vanity/urls', 'delay' => 6000 },
            propagate_synd_post: true,
            auth_checker:        {
              'url'     => '/path/to/auth/checker',
              'filters' => [{ 'rank' => 1, 'glob' => '*', 'allow' => false }, { 'rank' => 10, 'glob' => '/content/secure/*.html', 'allow' => true }],
              'headers' => [{ 'rank' => 1, 'glob' => '*', 'allow' => false }, { 'rank' => 10, 'glob' => 'Set-Cookie:*', 'allow' => true }],
            },
          )
        end
        it do
          is_expected.to contain_concat('dispatcher.50-customparams.inc.any').with(
            ensure: 'present',
            path:   "#{vhost_dir}/dispatcher.50-customparams.inc.any",
            owner:  'root',
            group:  'root',
            mode:   file_mode,
            order:  'numeric',
          ).that_requires('Package[httpd]').that_notifies('Class[apache::service]')
        end
      end
    end
  end
end
