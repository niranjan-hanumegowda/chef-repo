#
# Cookbook Name:: ntp
# Recipe:: default
#
# Copyright 2013, Gap, Inc.
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
package "ntp" do
  action [:install]
end

ntp_server = data_bag_item('ntp', 'default_server')

template "/etc/ntp.conf" do
  source "ntp.conf.erb"
  variables( :ntp_server => ntp_server['value'] )
  notifies :restart, "service[ntpd]"
end

service "ntpd" do
  action [:enable, :start]
end
