#
# Cookbook Name:: graylog2
# Recipe:: web
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
#include_recipe "ark"


# Download, extract, symlink the graylog2 libraries and binaries
#
#ark_prefix_root = node.graylog2[:dir] || node.ark[:prefix_root]
#ark_prefix_home = node.graylog2[:dir] || node.ark[:prefix_home]

#ark "graylog2-web" do
#  url   node.graylog2[:web][:download_url]
#  owner node.graylog2[:user]
#  group node.graylog2[:user]
#  version node.graylog2[:version]
#  has_binaries ['bin/graylog2-web-interface']
#  checksum node.graylog2[:checksum]
#  prefix_root   ark_prefix_root
#  prefix_home   ark_prefix_home

#  notifies :start,   'service[graylog2-web]'
#  notifies :restart, 'service[graylog2-web]' unless node.graylog2[:skip_restart]

#  not_if do
#    link   = "#{node.graylog2[:dir]}/graylog2-web"
#    target = "#{node.graylog2[:dir]}/graylog2-web-#{node.graylog2[:version]}"
#    binary = "#{target}/bin/graylog2-web-interface"

#    ::File.directory?(link) && ::File.symlink?(link) && ::File.readlink(link) == target && ::File.exists?(binary)
#  end
#end

remote_file "#{Chef::Config[:file_cache_path]}/#{node.graylog2[:web][:tarball]}" do
  source node.graylog2[:web][:download_url]
  mode 00644
  checksum node.graylog2[:checksum]
  ## notifies :run, "execute[unpack-web]", :immediately
end

execute "unpack-web" do
  user  "root"
  group "root"
  cwd   node.graylog2[:install_dir]
  ## action :nothing
  command "tar xzf #{Chef::Config[:file_cache_path]}/#{node.graylog2[:web][:tarball]}"
  creates "#{node.graylog2[:install_dir]}/graylog2-web-interface-#{node.graylog2[:version]}"
  notifies :run, "execute[chown-web]", :immediately
end

execute "chown-web" do
  command "chown -R #{node.graylog2[:user]}:#{node.graylog2[:user]} #{node.graylog2[:install_dir]}/graylog2-web-interface-#{node.graylog2[:version]}"
  action :nothing
end

link node.graylog2[:web][:home] do
  to "#{node.graylog2[:install_dir]}/graylog2-web-interface-#{node.graylog2[:version]}"
end

if Chef::Config[:solo]
  graylog2_servers = 'http://' + node.fqdn + ':12900/'
else
  es_results = search(:node, node.graylog2['elasticsearch_query'])
  if !es_results.empty?
    graylog2_servers = es_results.map { |n| 'http://' + n.fqdn + ':12900/' }.join(',')
  else
    log "Oops..Search results for Graylog2 Servers returned empty!! Settling for http://#{node.fqdn}:12900/"
    graylog2_servers = 'http://' + node.fqdn + ':12900/'
  end
end

# Create config files
#
template "#{node.graylog2[:web][:home]}/conf/graylog2-web-interface.conf" do
  source "graylog2-web-interface.conf.erb"
  owner node.graylog2[:user] and group node.graylog2[:user] and mode 0644
  variables(
            :graylog2_servers => graylog2_servers
           )
  notifies :restart, 'service[graylog2-web]' unless node.graylog2[:skip_restart]
end

# Create service
#
link "/etc/init.d/graylog2-web" do
  to "#{node.graylog2[:web][:home]}/bin/graylog2-web-interface"
end

service "graylog2-web" do
  supports :restart => false
  action [ :nothing ]
end

