#
# Cookbook Name:: graylog2
# Recipe:: default
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
# These two lines enables us to load custom methods from 
# files under 'libraries'
[Chef::Recipe, Chef::Resource].each { |l| l.send :include, ::Extensions }
Erubis::Context.send(:include, Extensions::Templates)

# This cookbook provides ark, a resource for managing software archives
include_recipe "ark"

# Create user and group
#
group node.graylog2[:user] do
  action   :create
  system   true
end

user node.graylog2[:user] do
  comment  "graylog2 User"
  home     "#{node.graylog2[:dir]}/graylog2"
  shell    "/bin/bash"
  gid      node.graylog2[:user]
  supports :manage_home => false
  action   :create
  system   true
end

# FIX: Work around the fact that Chef creates the directory even for `manage_home: false`
bash "remove the graylog2 user home" do
  user     'root'
  code     "rm -rf  #{node.graylog2[:dir]}/graylog2"
  not_if   "test -L #{node.graylog2[:dir]}/graylog2"
  only_if  "test -d #{node.graylog2[:dir]}/graylog2"
end


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
  es_servers = node['ipaddress'] + ':9300'
else
  es_results = search(:node, node.graylog2['elasticsearch_query'])
  if !es_results.empty?
    ###es_servers = es_results.map { |n| n.ipaddress + ':9300' }.join(',')
    es_servers = es_results.map { |n| n.ipaddress + ':9300' }
  else
    log "Oops..Search results for ES Servers returned empty!! Settling for #{node.ipaddress}:9300"
    es_servers = node['ipaddress'] + ':9300'
  end
end

# Create config files
#
template "/etc/graylog2.conf" do
  source "graylog2.conf.erb"
  owner 'root' and group 'root' and mode 0644
  variables(
            :es_servers => es_servers
           )
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

