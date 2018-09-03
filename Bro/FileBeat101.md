# Filebeat 101

## 1.Filebeat prospectors
a prospector to track multiple files 
define multiple prospectors in case you have prospector-specific configurations you want to apply.

## 2.Filebeat processors
Processors are defined in the Filebeat configuration file per prospector. 

## 3.Filebeat output
including console, file, cloud, Redis, Kafka but in most cases, you will be using the Logstash or Elasticsearch output types.
You can define multiple outputs and use a load balancing option to balance the forwarding of data.

```
# Examples:
filebeat.prospectors:
- type: log
  paths:
    - "/var/log/apache2/access.log"
  fields:
    apache: true
  processors:
  - drop_fields:
      fields: ["verb","id"]
output.logstash:
  hosts: ["localhost:5044"]
# OR to elasticsearch 
# output.elasticsearch:
#   hosts: ["localhost:9200"]
```

