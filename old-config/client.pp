class hg_vocmssdt::elastic::client inherits elastic {
firewall { "100 Accept [9300:9400] from masters":
      action => 'accept',
      source => $elastic::masters,
      dport  => [9300-9400],
      proto  => 'tcp',
 }
 firewall { "100 Accept [9300:9400] from data":
      action => 'accept',
      source => $elastic::data_nodes,
      dport  => [9300-9400],
      proto  => 'tcp',
 }
 firewall { "200 Accept [9200] from masters":
      action => 'accept',
      source => $elastic::masters,
      dport  => [9200],
      proto  => 'tcp',
 }
 firewall { "200 Accept [9200] from data nodes":
      action => 'accept',
      source => $elastic::data_nodes,
      dport  => [9200],
      proto  => 'tcp',
 }
 firewall { "200 Accept [9200] from cmssdt":
      action => 'accept',
      dport  => [9200],
      proto  => 'tcp',
 }
 firewall { "400 Accept [5601] from all":
      action => 'accept',
      dport  => [5601],
      proto  => 'tcp',
 }
 firewall { "500 Accept [80] from all":
      action => 'accept',
      dport  => [80],
      proto  => 'tcp',
 }
 file {['/data', '/data/logs']:
    ensure => directory,
    owner  => 'elasticsearch',
    group  => 'elasticsearch',
  }->
 mount {'/data':
    ensure  => 'mounted',
    device  => '/dev/vdc',
    fstype  => 'ext4',
    options => 'defaults',
    atboot  => true,
  }->
 file_line { 'elasticsearch_yml_server_host':
  ensure => present,
  path   => '/etc/elasticsearch/elasticsearch.yml',
  line   => 'network.host: localhost',
  match  => '^# network.host',
 }->
 file_line { 'elasticsearch_yml_data_node_data_dir':
  ensure => present,
  path   => '/etc/elasticsearch/elasticsearch.yml',
  line   => 'path.data: /data',
  match  => '^# path.data',
 }
 file_line { 'elasticsearch_yml_data_node_logs_dir':
  ensure => present,
  path   => '/etc/elasticsearch/elasticsearch.yml',
  line   => 'path.logs: /data/logs',
  match  => '^# path.logs',
 }->
 service { 'elasticsearch':
    ensure  => running,
    require => Package [ 'elasticsearch' ],
  }
 group {'kibana':
    gid => 1006,
 }->
 user {'kibana':
    uid => 202,
    gid => 'kibana',
    ensure => present,
 }->
 file {"/opt/kibana":
    ensure  => 'directory',
    owner  => 'kibana',
    group  => 'kibana',
    mode    => '0775',
 }->
 exec {"download_kibana":
    command => "/usr/bin/wget https://download.elastic.co/kibana/kibana/kibana-4.3.0-linux-x64.tar.gz",
    cwd     => "/opt/kibana",
    creates => "/opt/kibana/kibana-4.3.0-linux-x64.tar.gz",
    user    => 'kibana',
 }->
 exec {"install_kibana":
   command => '/bin/tar -xzvf kibana-4.3.0-linux-x64.tar.gz',
   cwd     => "/opt/kibana",
   creates => "/opt/kibana/kibana-4.3.0-linux-x64",
   user    => "kibana",
 }->
 file {'/opt/kibana/kibana-4.3.0-linux-x64/config/kibana.yml':
    source => 'puppet:///modules/hg_vocmssdt/opt/kibana/config/kibana.yml',
    mode   => '0644',
    owner  => 'kibana',
    group  => 'kibana',
 }->
 file_line { 'kibana_yml_host':
  ensure => present,
  path   => '/opt/kibana/kibana-4.3.0-linux-x64/config/kibana.yml',
  line   => join([ 'server.host:' , join([ '"',$ipaddress_eth0, '"' ], "") ], " ") ,
  match  => '^[# ]*server.host',
 }->
 exec {"enable_kibana":
   command => '/bin/ln -s /opt/kibana/kibana-4.3.0-linux-x64/bin/kibana /etc/init.d/kibana',
   creates => "/etc/init.d/kibana",
   user    => "root",
 }->
 exec {"run_kibana":
   command => '/opt/kibana/kibana-4.3.0-linux-x64/bin/kibana serve &',
   user	   => "kibana",
 }
}
