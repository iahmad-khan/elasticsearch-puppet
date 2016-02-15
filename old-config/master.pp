class hg_vocmssdt::elastic::master inherits elastic {
firewall { "100 Accept [9300:9400] from clients":
      action => 'accept',
      source => $elastic::clients,
      dport  => [9300-9400],
      proto  => 'tcp',
 }
 firewall { "100 Accept [9300:9400] from data":
      action => 'accept',
      source => $elastic::data_nodes,
      dport  => [9300-9400],
      proto  => 'tcp',
 }
 firewall { "200 Accept [9200] from clients":
      action => 'accept',
      source => $elastic::clients,
      dport  => [9200],
      proto  => 'tcp',
 }
 firewall { "200 Accept [9200] from data nodes":
      action => 'accept',
      source => $elastic::data_nodes,
      dport  => [9200],
      proto  => 'tcp',
 }
 file_line { 'elasticsearch_yml_master_node_type1':
  ensure => present,
  path   => '/etc/elasticsearch/elasticsearch.yml',
  line   => 'node.master: true',
  match  => '^[# ]*node.master',
 }  
 file_line { 'elasticsearch_yml_master_node_type2':
  ensure => present,
  path   => '/etc/elasticsearch/elasticsearch.yml',
  line   => 'node.data: false',
  match  => '^[# ]*node.data',
 }  
}
