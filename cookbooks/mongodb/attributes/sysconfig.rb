include_attribute "mongodb::default"

default['mongodb']['sysconfig']['DAEMON'] = "/usr/bin/mongod"
default['mongodb']['sysconfig']['DAEMON_USER'] = node['mongodb']['user']
default['mongodb']['sysconfig']['CONFIGFILE'] = node['mongodb']['configfile']
default['mongodb']['sysconfig']['PORT'] = node['mongodb']['port']
default['mongodb']['sysconfig']['DBPATH'] = node['mongodb']['dbpath']
default['mongodb']['sysconfig']['LOG'] = node['mongodb']['log']
default['mongodb']['sysconfig']['DAEMON_OPTS'] = "--config $CONFIGFILE --port $PORT --dbpath $DBPATH --logpath $LOG --fork"
default['mongodb']['sysconfig']['ENABLE_MONGODB'] = "yes"
