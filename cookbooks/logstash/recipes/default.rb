#
# Cookbook Name:: logstash
# Recipe:: default
#
# Copyright 2014, Gap, Inc.
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
if node['logstash']['create_account']

  group node['logstash']['group'] do
    system true
    gid node['logstash']['gid']
  end

  user node['logstash']['user'] do
    group node['logstash']['group']
    system true
    action :create
    manage_home false
    uid node['logstash']['uid']
  end

end

directory node['logstash']['basedir'] do
  action :create
  owner node['logstash']['user']
  group node['logstash']['group']
  mode '0755'
end

node['logstash']['join_groups'].each do |grp|
  group grp do
    members node['logstash']['user']
    action :modify
    append true
    only_if "grep -q '^#{grp}:' /etc/group"
  end
end
