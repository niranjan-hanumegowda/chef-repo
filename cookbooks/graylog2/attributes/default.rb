# Load settings from data bag 'graylog2/settings'
#
settings = Chef::DataBagItem.load('graylog2', 'settings')[node.chef_environment] rescue {}
Chef::Log.debug "Loaded settings: #{settings.inspect}"

# Initialize the node attributes with node attributes merged with data bag attributes
#
node.default[:graylog2] ||= {}
node.normal[:graylog2]  ||= {}
node.normal[:graylog2]    = DeepMerge.merge(node.default[:graylog2].to_hash, node.normal[:graylog2].to_hash)
node.normal[:graylog2]    = DeepMerge.merge(node.normal[:graylog2].to_hash, settings.to_hash)


# === VERSION AND LOCATION
#
default.graylog2[:version]       = "0.90.5"
default.graylog2[:host]          = "http://download.graylog2.org"
default.graylog2[:repository]    = "graylog2/graylog2"
default.graylog2[:filename]      = "graylog2-#{node.graylog2[:version]}.tar.gz"
default.graylog2[:download_url]  = [node.graylog2[:host], node.graylog2[:repository], node.graylog2[:filename]].join('/')

# === NAMING
#
default.graylog2[:cluster][:name] = 'graylog2'
default.graylog2[:node][:name]    = node.name

# === USER & PATHS
#
default.graylog2[:dir]       = "/usr/local"
default.graylog2[:user]      = "graylog2"
