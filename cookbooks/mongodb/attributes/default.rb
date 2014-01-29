# Load settings from data bag 'mongodb/settings'
#
settings = Chef::DataBagItem.load('mongodb', 'settings')[node.chef_environment] rescue {}
Chef::Log.debug "Loaded settings: #{settings.inspect}"

# Initialize the node attributes with node attributes merged with data bag attributes
#
node.default[:mongodb] ||= {}
node.normal[:mongodb]  ||= {}
node.normal[:mongodb]    = DeepMerge.merge(node.default[:mongodb].to_hash, node.normal[:mongodb].to_hash)
node.normal[:mongodb]    = DeepMerge.merge(node.normal[:mongodb].to_hash, settings.to_hash)


default.mongodb[:version]         = "2.2.27"
default.mongodb[:download_url]    = "http://fastdl.mongodb.org"
default.mongodb[:repository]      = "linux"
default.mongodb[:filename]        = "mongodb-#{node.mongodb[:repository]}-#{node['machine']}-#{node.mongodb[:version]}.tgz"


default.mongodb[:user]            = "mongod"
default.mongodb[:dir]             = "/usr/local"

# === LIMITS
#
# By default, the `mlockall` is set to true: on weak machines and Vagrant boxes,
# you may want to disable it.
#
default.mongodb[:bootstrap][:mlockall] = ( node.memory.total.to_i >= 1048576 ? true : false )
default.mongodb[:limits][:memlock] = 'unlimited'
default.mongodb[:limits][:nofile]  = '64000'
