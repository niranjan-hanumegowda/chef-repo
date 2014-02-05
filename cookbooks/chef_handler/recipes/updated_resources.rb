include_recipe 'chef_handler::default'

chef_handler "UpdatedResources" do
  source "#{node['chef_handler']['handler_path']}/updated_resources.rb"
  action :enable
end
