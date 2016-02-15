class hg_vocmssdt::esmaster {
firewall {'9300 es transport':
     proto  => 'tcp',
     dport  => '9300',
     action => 'accept',
 }
firewall {'9200 es':
     proto  => 'tcp',
     dport  => '9200',
     action => 'accept',
 }
firewall {'5601 kibana':
     proto  => 'tcp',
     dport  => '5601',
     action => 'accept',
 }
osrepos::ai121yumrepo { 'elasticsearch-1.4':
   descr    => 'Elasticsearch repository for 1.4.x packages',
   baseurl  => 'http://linuxsoft.cern.ch/elasticsearch/elasticsearch-x86_64/RPMS.es-14-el6/',
   gpgcheck => 1,
   gpgkey   => 'http://linuxsoft.cern.ch/elasticsearch/GPG-KEY-elasticsearch',
   enabled  => 1,
   priority => 99,
 }
 $es_user = 'elasticsearch'
 $es_pkg_name = 'elasticsearch'
 class { '::elasticsearch':
   package_name => $es_pkg_name,
   config       => {
     'node' => {
       'name' => $::hostname,
       'master' => 'true',
       'data' => 'false',
     },
     'cluster' => {
       'name' => "test-cluster",  # you might want to change that
     },
     'action' => {
       'disable_delete_all_indices' => 'true',
     },
     'index' => {
       'number_of_replicas' => '1',    # see footnote 1.
       'number_of_shards' => '2',    # see footnote 2.
     },
     'index.analysis.analyzer.default.tokenizer' => 'whitespace',
     'index.cache.field.type' => 'soft',
     'index.routing.allocation.disable_allocation' => 'false',
     'discovery.zen.ping.multicast.enabled' => 'false',
     'discovery.zen.ping.timeout' => '10s',
   },
   init_defaults => {
     'ES_HEAP_SIZE' => '2g',  # !! must be exactly equal to 50% of the RAM !!
     'ES_GROUP' => $es_user,
     'ES_USER' => $es_user,
     'CONF_DIR' => '/etc/elasticsearch',
     'LOG_DIR' => '/var/log/elasticsearch',
     'DATA_DIR' => '/var/lib/elasticsearch',
     'WORK_DIR' => '/tmp/elasticsearch',
   },
 } ->
 exec { 'install_elasticsearch_hq':
   command => '/usr/share/elasticsearch/bin/plugin -i royrusso/elasticsearch-HQ',
   unless  => '/usr/bin/test -d /usr/share/elasticsearch/plugins/HQ',
 } ->
 exec { 'install_elasticsearch_kibana':
   command => '/usr/share/elasticsearch/bin/plugin -url http://download.elasticsearch.org/kibana/kibana/kibana-latest.zip -i kibana',
   unless  => '/usr/bin/test -d /usr/share/elasticsearch/plugins/kibana',
 }
}
