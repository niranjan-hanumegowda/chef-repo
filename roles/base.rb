name "base"
description "base role"
run_list [
    "recipe[chef_handler::default]",
    "recipe[chef_handler::updated_resources]",
    "recipe[chef_handler::cookbook_versions]",
    "recipe[lsof]", 
    "recipe[ntp]",
    "recipe[chef-client]",
    ]
