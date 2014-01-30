name "graylog2"
description "graylog2 role"
run_list [
    "recipe[java]",
    "recipe[elasticsearch]", 
    "recipe[mongodb]",
    "recipe[graylog2]"
    ]
override_attributes(
  :java => {
    :jdk_version => "7"
  },
  :elasticsearch => {
    :version => "0.90.10"
  }
)
