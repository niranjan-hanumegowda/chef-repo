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
            path: ["/var/log/logstash/*.log"],
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
          stdout: {
            codec: 'rubydebug'
          },
          gelf: {
            host: '192.168.33.11',
            port: '12201',
          }
        }
      ]
    }
  }
)
