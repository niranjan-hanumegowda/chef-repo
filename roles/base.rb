name "base"
description "base role"
run_list [
    "recipe[lsof]", 
    "recipe[ntp]",
    "recipe[chef-client]"
    ]
