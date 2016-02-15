class hg_vocmssdt::elastic::data inherits elastic {
 firewall { "100 Accept [9300:9400] from masters":
      action => 'accept',
      source => $elastic::masters,
      dport  => [9300-9400],
      proto  => 'tcp',
  }
  firewall { "100 Accept [9300:9400] from clients":
      action => 'accept',
      source => $elastic::clients,
      dport  => [9300-9400],
      proto  => 'tcp',
  }
  firewall { "200 Accept [9200] from masters":
      action => 'accept',
      source => $elastic::masters,
      dport  => [9200],
      proto  => 'tcp',
  }
  firewall { "200 Accept [9200] from data clients":
      action => 'accept',
      source => $elastic::clients,
      dport  => [9200],
      proto  => 'tcp',
  }
  mount {'/data':
    ensure  => 'mounted',
    device  => '/dev/vdc',
    fstype  => 'ext4',
    options => 'defaults',
    atboot  => true,
  }->
  file {['/data', '/data/logs']:
    ensure => directory,
    mode   => '0600',
    owner  => 'elasticsearch',
    group  => 'elasticsearch',
  }
 file_line { 'elasticsearch_yml_data_node_type1':
  ensure => present,
  path   => '/etc/elasticsearch/elasticsearch.yml',
  line   => 'node.master: false',
  match  => '^[# ]*node.master',
 }  
 file_line { 'elasticsearch_yml_data_node_type2':
  ensure => present,
  path   => '/etc/elasticsearch/elasticsearch.yml',
  line   => 'node.data: true',
  match  => '^[# ]*node.data',
 }  
 file_line { 'elasticsearch_yml_data_node_data_dir':
  ensure => present,
  path   => '/etc/elasticsearch/elasticsearch.yml',
  line   => 'path.data: /data',
  match  => '^[# ]*path.data',
 }  
 file_line { 'elasticsearch_yml_data_node_logs_dir':
  ensure => present,
  path   => '/etc/elasticsearch/elasticsearch.yml',
  line   => 'path.logs: /data/logs',
  match  => '^[# ]*path.logs',
 }  
}
