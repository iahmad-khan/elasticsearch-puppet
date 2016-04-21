class elastic {
file {"/var/opt/increase.sh":
    source => "puppet:///modules/hg_vocmssdt/lvm_increase/increase.sh",
    mode => 755,
    owner => "root",
    group => "root",
  }->
  exec {"increase_lv_size":
    command => "/var/opt/increase.sh",
    unless => "/usr/bin/test -e /etc/volume_expanded",
    require => File["/var/opt/increase.sh"]
  }
}
