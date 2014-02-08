include_recipe 'chef_handler'

chef_handler "SimpleReport::UpdatedResources" do
  source "#{node['chef_handler']['handler_path']}/updated_resources.rb"
  action :enable
end
