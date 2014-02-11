# === GRAYLOG2-WEB
#
default.graylog2[:web][:tarball]      = "graylog2-web-interface-#{node.graylog2[:version]}.tgz"
default.graylog2[:web][:download_url] = "https://github.com/Graylog2/graylog2-web-interface/releases/download/#{node.graylog2[:version]}/#{node.graylog2[:web][:tarball]}"
default.graylog2[:web][:graylog2_server_query] = "graylog2_server:#{node.graylog2[:server]} AND chef_environment:#{node.chef_environment}"
default.graylog2[:web][:home] = "#{node.graylog2[:install_dir]}/graylog2-web"
##default.graylog2[:web][:settings][:graylog2_server_uris] = "http://127.0.0.1:12900/"
