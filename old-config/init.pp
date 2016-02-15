class hg_vocmssdt::elastic inherits hg_vocmssdt {
 $clients = query_nodes('hostgroup="vocmssdt/elastic/client"', ipaddress_eth0)
 $masters = query_nodes('hostgroup="vocmssdt/elastic/master"', ipaddress_eth0)
 $data_nodes = query_nodes('hostgroup="vocmssdt/elastic/data"', ipaddress_eth0)
 $cms_es_nodes = join([$clients , $masters , $data_nodes ],'","')
 osrepos::ai121yumrepo { 'elasticsearch':
    baseurl  => 'http://packages.elastic.co/elasticsearch/2.x/centos',
    descr    => 'Elasticsearch official repository',
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'http://packages.elastic.co/GPG-KEY-elasticsearch',
  }->
  package {'elasticsearch':
    ensure  => '2.1.1-1',
    require => Osrepos::Ai121yumrepo[ 'elasticsearch' ],
  }->
  group {'elasticsearch':
    gid => 496,
  }->
  user {'elasticsearch':
    uid => 203,
    gid => 'elasticsearch',
  }->
 file { '/etc/elasticsearch':
   ensure => 'directory',
   owner   => 'elasticsearch',
   group  => 'elasticsearch',
 }->
 file { '/var/log/elasticsearch':
   ensure => 'directory',
   owner  => 'elasticsearch',
   group  => 'elasticsearch',
 }->
 file { '/var/lib/elasticsearch':
   ensure => 'directory',
   owner  => 'elasticsearch',
   group  => 'elasticsearch',
 }->
 file { '/var/run/elasticsearch':
   ensure => 'directory',
   owner  => 'elasticsearch',
   group  => 'elasticsearch',
 }->
 file_line { 'elasticsearch_yml_memlock':
  ensure => present,
  path   => '/etc/elasticsearch/elasticsearch.yml',
  line   => 'bootstrap.mlockall: true',
  match  => '^# bootstrap.mlockall',
 }
}
