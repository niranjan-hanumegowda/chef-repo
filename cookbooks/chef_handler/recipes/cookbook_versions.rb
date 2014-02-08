include_recipe "chef_handler"

chef_handler "Opscode::CookbookVersionsHandler" do
  source "#{node["chef_handler"]["handler_path"]}/cookbook_versions.rb"
  supports :report => true
  action :enable
end
