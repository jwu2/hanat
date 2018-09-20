class hanat (
  $peerinstanceid,
  $peerroutetableid,
  $myroutetableid,
  $num_pings                = 3,
  $ping_timeout             = 1,
  $ping_interval            = 5,
  $wait_between_pings       = 5,
  $wait_for_instance_stop   = 300,
  $wait_for_instance_start  = 300,
  $scriptfile               = '/opt/nat_monitor',
  $logfile                  = '/opt/nat_monitor.log'

  ){

  if ! defined(Package['awscli']) {
    package {'awscli': }
  }

  sysctl { 'net.ipv4.ip_forward':
    value     => '1',
    require   => Package['iptables-persistent']
  }

  firewall { '950 masq':
    chain => 'POSTROUTING',
    jump  => 'MASQUERADE',
    proto => 'all',
    table => 'nat',
  }

  $filename = (split($scriptfile,'/'))[-1]

  file { $scriptfile:
    ensure  => file,
    mode    => '0755',
    content => template("${module_name}/nat_monitor.erb"),
    notify  => Exec["kill ${filename}"]
  }

  cron { $filename:
    command => "${scriptfile} >> ${logfile}",
    special => 'reboot',
    user => 'root',
    require => File[$scriptfile]
  }

  exec { "kill ${filename}":
    command     => "/usr/bin/killall ${filename}",
    onlyif      => "/bin/ps cax | grep ${filename}",
    require     => File[$scriptfile],
    refreshonly => true,
    before      => Exec[$filename]
  }

  exec { $filename:
    command     => "${scriptfile} >> ${logfile} &",
    unless      => "/bin/ps cax | grep ${filename}",
    require     => [File[$scriptfile],Package['awscli']]
  }
}