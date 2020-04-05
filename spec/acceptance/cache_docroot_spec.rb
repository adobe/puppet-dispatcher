# frozen_string_literal: true

#
# Puppet Dispatcher Module - A module to manage AEM Dispatcher installations and configuration files.
#
# Copyright 2019 Adobe Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper_acceptance'
require 'serverspec'
require 'puppet_litmus'
include PuppetLitmus

dispatcher_target  = 'apache2.4'
dispatcher_version = '4.3.3'
dispatcher_file    = "dispatcher-#{dispatcher_target}-#{dispatcher_version}.so"
dispatcher_tarfile = "dispatcher-#{dispatcher_target}-linux-x86_64-#{dispatcher_version}.tar.gz"
dispatcher_src     = "http://download.macromedia.com/dispatcher/download/#{dispatcher_tarfile}"
inventory_hash     = inventory_hash_from_inventory_file
node_config        = facts_from_node(inventory_hash, ENV['TARGET_HOST'])
platform           = node_config.dig('platform')

case platform
when %r{(centos|oracle|scientific)}
  service   = 'httpd'
when %r{(debian|ubuntu)}
  service   = 'apache2'
else
  raise 'Unknown platform.'
end

describe 'dispatcher' do
  context 'cache docroot' do
    describe 'is idempotent' do
      let(:pp) do
        <<~PUPPETCODE
          $dir = '/tmp/dispatcher'
          file { $dir :
            ensure => directory
          }
          archive { '#{dispatcher_tarfile}' :
            path         => "$dir/#{dispatcher_tarfile}",
            source       => "#{dispatcher_src}",
            extract      => true,
            extract_path => $dir,
            creates      => "$dir/#{dispatcher_file}",
            require      => File[$dir],
          }
          class { 'apache' :
            default_vhost     => false,
            default_ssl_vhost => false,
          }
          apache::vhost { 'managedocroot' :
            port           => '80',
            default_vhost  => true,
            docroot        => '/var/www/html',
            manage_docroot => false,
          }
          class { 'dispatcher' :
            module_file => "$dir/#{dispatcher_file}",
            require     => Archive['#{dispatcher_tarfile}']
          }
          dispatcher::farm { 'default' :
            renderers => [{ hostname => 'localhost', port => 4503 }],
            filters   => [{ 'allow' => false, 'rank' => 1, 'url' => { 'regex' => true, 'pattern' => '.*' }}],
            cache     => {
              docroot         => '/var/www/html',
              manage_docroot  => true,
              rules           => [{ 'rank' => 1, 'glob' => '*.html', 'allow' => true }],
              allowed_clients => [{ 'rank' => 1, 'glob' => '*.*.*.*', 'allow' => false }],
            },
          }
        PUPPETCODE
      end

      it { expect(idempotent_apply(pp)).to be_truthy }
    end
    describe service(service) do
      it { is_expected.to be_running }
    end
  end
end
