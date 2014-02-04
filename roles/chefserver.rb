name "chefserver"
description "Chef Server role"
run_list [
    "recipe[chef_handler::gelf]"
    ]
