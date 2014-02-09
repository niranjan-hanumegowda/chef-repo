# Custom GELF Fields that you would like to be indexed
default["chef_handler"]["gelf"]["custom_fields"] = {
  :chef_environment => node.chef_environment,
  :ipaddress => node.ipaddress,
  :os => node.os,
  :uptime => node.uptime,
}

# Specify Blacklist to reduce updated_resources noise
default["chef_handler"]["gelf"]["blacklist"] = {
  :chef_handler => {
    :chef_handler => [ "nothing", "enable" ]
  },
  :lsof => {
    :log => [ "write" ]
  },
}
