name "graylog2-primary"
description "The Primary Graylog2 Server. This includes the Web-UI"

run_list [
    "recipe[java::default]",
    "recipe[elasticsearch]",
    "recipe[mongodb]",
    "recipe[graylog2::server]",
    "recipe[graylog2::web]"
    ]

override_attributes(
  :java => {
    :jdk_version => "7"
  }
)
