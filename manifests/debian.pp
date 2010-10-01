class stunnel::debian inherits stunnel::linux {
  
  Package[stunnel] {
    name => 'stunnel4',
  }
  
  Service[stunnel] {
    name => 'stunnel4',
    pattern => '/usr/bin/stunnel4',
  }
  
  # make the /etc/default/stunnel ENABLED configurable with a variable
  # and default to on
  case $stunnel_startboot {
    '': { $stunnel_startboot = '1' }
  }
  # make the /etc/default/stunnel extra configurable with a variable
  # and default to adding nothing to the default file
  case $stunnel_default_extra {
    '': { $stunnel_default_extra = '' }
  }
  
  file { '/etc/default/stunnel4':
    content => template("stunnel/Debian/default"),
    require => Package['stunnel4'],
    notify => Service['stunnel4'],
    owner => root, group => 0, mode => 0644;
  }
}

