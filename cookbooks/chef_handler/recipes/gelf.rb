log_server = search(:node, "role:graylog2").first

if log_server
  include_recipe "chef_handler::default"

  gem_package "chef-gelf" do
    action :nothing
  end.run_action(:install)

  # Make sure the newly installed Gem is loaded.
  #Gem.clear_paths
  #require 'chef/gelf'

  #chef_handler "Chef::GELF::Handler" do
  #  source "chef/gelf"
  #  arguments({
  #    :server => log_server['fqdn']
  #  })

  #  supports :exception => true, :report => true
  #end.run_action(:enable)

  chef_handler "Chef::GELF::Handler" do
    source "#{node['chef_handler']['handler_path']}/gelf.rb"
    arguments({
      :host => log_server['fqdn']
    })
  end.run_action(:enable)

end
