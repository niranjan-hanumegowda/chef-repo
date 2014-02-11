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
default.graylog2[:version]          = "0.20.0-rc.1-1"
default.graylog2[:server_tarball]   = "graylog2-server-#{node.graylog2[:version]}.tgz"
default.graylog2[:download_url]     = "https://github.com/Graylog2/graylog2-server/releases/download/#{node.graylog2[:version]}/#{node.graylog2[:server_tarball]}.tgz"
default.graylog2[:web_tarball]      = "graylog2-web-interface-#{node.graylog2[:version]}.tgz"
default.graylog2[:web_download_url] = "https://github.com/Graylog2/graylog2-web-interface/releases/download/#{node.graylog2[:version]}/#{node.graylog2[:web_tarball]}.tgz"

# === USER & PATHS
#
default.graylog2[:install_dir] = "/opt"
default.graylog2[:home]        = "#{node.graylog2[:install_dir]}/graylog2"
default.graylog2[:user]        = "graylog2"

# === Attributes for various search/discovery
#
default.graylog2[:server] = "true"
default.graylog2[:elasticsearch_cluster] = 'graylog2'
default.graylog2[:elasticsearch_query] = "elasticsearch_cluster_name:#{node.graylog2[:elasticsearch_cluster]} AND chef_environment:#{node.chef_environment}"
default.graylog2[:mongo_query] = "role:graylog2-primary AND chef_environment:#{node.chef_environment}"

# === SETTINGS
#
default.graylog2[:settings][:password_secret]    = "i@m@l0ng64b1tm3ss@g3w@1t1ngt0b3d3c0d3dbr1ng1t0nb1tch0k@y12m0r3t0g0"
default.graylog2[:settings][:root_password_sha2] = "d32376994ba5d1e088564a8fefe258e3fdc33c8476fac7452b5d17bef9a68803"
##default.graylog2[:settings][:elasticsearch_discovery_zen_ping_unicast_hosts] = "127.0.0.1:9300"

# === GRAYLOG2-WEB
#
default.graylog2[:web][:graylog2_server_query] = "graylog2_server:#{node.graylog2[:server]} AND chef_environment:#{node.chef_environment}"
default.graylog2[:web][:home] = "#{node.graylog2[:install_dir]}/graylog2-web"
##default.graylog2[:web][:settings][:graylog2_server_uris] = "http://127.0.0.1:12900/"

