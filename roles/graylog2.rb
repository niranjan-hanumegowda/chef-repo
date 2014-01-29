name "graylog2"
description "graylog2 role"
run_list [
    "recipe[elasticsearch]", 
    "recipe[mongodb]"
    ]
override_attributes(
  :java => {
    :jdk_version => "7"
  },
  :elasticsearch => {
    :version => "0.90.10"
  },
  :mongodb => {
    :package_version => "2.4.9"
  }
)
