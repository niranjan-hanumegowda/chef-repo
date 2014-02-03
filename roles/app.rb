name "app"
description "Application Role"
run_list [
    "recipe[java]",
    "recipe[logstash::agent]"
    ]
override_attributes(
  :java => {
    :jdk_version => "7"
  },
  :logstash => {
    :agent =>   {
      inputs: [
        {
          file: {
            type: 'syslog',
            path: ["/var/log/*.log"],
            exclude: ["*.gz"],
            debug: true
          }
        }
      ],
      filters: [
        { 
          condition: 'if [type] == "syslog"',
          block: {    
            grok: {
              match: [
                "message",
                "%{SYSLOGTIMESTAMP:timestamp} %{IPORHOST:host} (?:%{PROG:program}(?:\[%{POSINT:pid}\])?: )?%{GREEDYDATA:message}"
              ]
            },
          }
        }
      ],
      outputs: [
        {
          gelf: {
            host: '192.168.33.11',
            port: '12201',
            full_message: "%{message}",
            type: "%{type}",
            custom_fields: [ "ip", node.ipaddress ],
          }
        }
      ]
    }
  }
)
