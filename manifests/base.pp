class stunnel::base {

  file { "/etc/stunnel":
    ensure => directory;
  }

  service { 'stunnel':
    name => 'stunnel',
    enable => true,
    ensure => $stunnel::ensure_version ? {
      absent  => stopped,
      default => running
    },
    hasstatus => false;
  }
}
