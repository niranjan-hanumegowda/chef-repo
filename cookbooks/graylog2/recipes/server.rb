#
# Cookbook Name:: graylog2
# Recipe:: server
#
# Copyright 2014, Custom, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# 

include_recipe "graylog2::default"
include_recipe "ark"


# Download, extract, symlink the graylog2 libraries and binaries
#
ark_prefix_root = node.graylog2[:dir] || node.ark[:prefix_root]
ark_prefix_home = node.graylog2[:dir] || node.ark[:prefix_home]

ark "graylog2" do
  url   node.graylog2[:download_url]
  owner node.graylog2[:user]
  group node.graylog2[:user]
  version node.graylog2[:version]
  has_binaries ['bin/graylog2ctl']
  checksum node.graylog2[:checksum]
  prefix_root   ark_prefix_root
  prefix_home   ark_prefix_home

  notifies :start,   'service[graylog2]'
  notifies :restart, 'service[graylog2]' unless node.graylog2[:skip_restart]

  not_if do
    link   = "#{node.graylog2[:dir]}/graylog2"
    target = "#{node.graylog2[:dir]}/graylog2-#{node.graylog2[:version]}"
    binary = "#{target}/bin/graylog2ctl"

    ::File.directory?(link) && ::File.symlink?(link) && ::File.readlink(link) == target && ::File.exists?(binary)
  end
end

if Chef::Config[:solo]
  es_servers = node['fqdn'] + ':9300'
else
  es_results = search(:node, node.graylog2['elasticsearch_query'])
  if !es_results.empty?
    es_servers = es_results.map { |n| n.fqdn + ':9300' }.join(',')
    ###es_servers = es_results.map { |n| n.fqdn + ':9300' }
  else
    log "Oops..Search for ES Servers returned empty!! Settling for #{node.fqdn}:9300"
    es_servers = node['fqdn'] + ':9300'
  end
end

if Chef::Config[:solo]
  mongo_server = 'localhost'
else
  mongo_results = search(:node, node.graylog2['mongo_query'])
  if !mongo_results.empty?
    mongo_server = mongo_results.first.fqdn
  else
    log "Oops..Search for Mongo Servers returned empty!! Settling for localhost"
    mongo_server = 'localhost'
  end
end

# Create config files
#
template "/etc/graylog2.conf" do
  source "graylog2.conf.erb"
  owner 'root' and group 'root' and mode 0644
  variables(
            :es_servers => es_servers,
            :mongo_server => mongo_server
           )
  notifies :restart, 'service[graylog2]' unless node.graylog2[:skip_restart]
end

template "/etc/graylog2.drl" do
  source "graylog2.drl.erb"
  owner 'root' and group 'root' and mode 0644
  notifies :restart, 'service[graylog2]' unless node.graylog2[:skip_restart]
end

# Create service
#
link "/etc/init.d/graylog2" do
  to "#{node.graylog2[:dir]}/graylog2/bin/graylog2ctl"
end

service "graylog2" do
  supports :status => true, :restart => true
  action [ :nothing ]
end
