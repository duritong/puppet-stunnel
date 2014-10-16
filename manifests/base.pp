class stunnel::base {

  file { "/etc/stunnel":
    ensure => directory;
  }

  service { 'stunnel':
    name => 'stunnel',
    enable => true,
    ensure => running,
    hasstatus => false;
  }
}
