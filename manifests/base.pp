class stunnel::base($ensure = present) {
  file { "/etc/stunnel":
    ensure => $ensure ? {
      absent  => absent,
      default => directory
    };
  }

  service { 'stunnel':
    name      => 'stunnel',
    enable    => true,
    ensure    => $ensure ? {
      absent  => absent,
      default => running
    },
    hasstatus => false;
  }
}
