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


default.mongodb[:version]         = "2.4.9"
default.mongodb[:host]            = "http://fastdl.mongodb.org"
default.mongodb[:repository]      = "linux"
default.mongodb[:filename]        = "mongodb-#{node.mongodb[:repository]}-x86_64-#{node.mongodb[:version]}.tgz"
default.mongodb[:download_url]    = [node.mongodb[:host], node.mongodb[:repository], node.mongodb[:filename]].join('/')


default.mongodb[:user]            = "mongod"
default.mongodb[:dir]             = "/usr/local"
default.mongodb[:configfile]      = "/etc/mongod.conf"
default.mongodb[:port]            = "27017"
default.mongodb[:dbpath]          = "/var/lib/mongodb"
default.mongodb[:log]             = "/var/log/mongodb/mongod.log"

# === LIMITS
#
# By default, the `mlockall` is set to true: on weak machines and Vagrant boxes,
# you may want to disable it.
#
default.mongodb[:bootstrap][:mlockall] = ( node.memory.total.to_i >= 1048576 ? true : false )
default.mongodb[:limits][:memlock] = 'unlimited'
default.mongodb[:limits][:nofile]  = '64000'

default.mongodb['sysconfig']['DAEMON'] = "/usr/bin/mongod"
default.mongodb['sysconfig']['DAEMON_USER'] = node['mongodb']['user']
default.mongodb['sysconfig']['CONFIGFILE'] = node['mongodb']['configfile']
default.mongodb['sysconfig']['PORT'] = node['mongodb']['port']
default.mongodb['sysconfig']['DBPATH'] = node['mongodb']['dbpath']
default.mongodb['sysconfig']['LOG'] = node['mongodb']['log']
default.mongodb['sysconfig']['DAEMON_OPTS'] = "--config $CONFIGFILE --port $PORT --dbpath $DBPATH --logpath $LOG --fork"
default.mongodb['sysconfig']['ENABLE_MONGODB'] = "yes"
