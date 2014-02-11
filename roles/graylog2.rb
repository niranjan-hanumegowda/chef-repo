name "graylog2"
description "Graylog2 Server role"
run_list [
    "recipe[java::default]",
    "recipe[graylog2::server]",
    ]
override_attributes(
  :java => {
    :jdk_version => "7"
  },
)
