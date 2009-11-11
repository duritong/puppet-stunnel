#
# stunnel puppet module
#
# Copyright 2009, Riseup Networks <micah@riseup.net>
#
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#
# 1. include stunnel: this will automatically include stunnel::debian,
#    which automatically includes stunnel::linux, which automatically
#    includes stunnel::base
# 2. stunnel::client allows you to configure different /etc/stunnel/*.conf files
#    to provide various stunnel configurations

# TODO: warn on cert/key issues, fail on false accept?

class stunnel {

  case $operatingsystem {
    debian: { include stunnel::debian }
    default: { include stunnel::default }
  }

  define service ( $ensure = present, $accept = false, $capath = false,
                  $cafile = false, $cert = false, $chroot = false,
                  $ciphers = false, $client = false, $compress =
                  false, $connect = false, $crlpath = false, $crlfile
                  = false, $debug = false, $delay = false, $egd =
                  false, $engine = false, $engineCtrl = false,
                  $enginenum = false, $exec = false, $execargs =
                  false, $failover = false, $ident = false, $key =
                  false, $local = false, $oscp = false, $ocspflag =
                  false, $options = false, $output = false, $pid =
                  false, $protocol = false, $protocolauthentication =
                  false, $protocolhost = false, $protocolpassword =
                  false, $protocolusername = false, $pty = false,
                  $retry = false, $rndbytes = false, $rndfile = false,
                  $rndoverwrite = false, $service = false, $session =
                  false, $setuid = "stunnel4", $setgid = "stunnel4",
                  $socket = [ "l:TCP_NODELAY=1", "r:TCP_NODELAY=1"],
                  $sslversion = "SSLv3", $stack = false, $syslog =
                  false, $timeoutbusy = false, $timeoutclose = false,
                  $timeoutconnect = false, $timeoutidle = false,
                  $transparent = false, $verify = false ) {

    $real_client = $client ? { default => "yes" }
    $real_pid = $pid ? { false => "/${name}.pid", default => $pid }
                    
    file { "/etc/stunnel/${name}.conf":
      ensure => $ensure,
      content => template('stunnel/service.conf.erb'), 
      owner => root, group => 0, mode => 0600,
      require => File["/etc/stunnel"],
      notify => Service[stunnel];
    }
  }
}

class stunnel::base {
  
  case $stunnel_ensure_version {
    '': { $stunnel_ensure_version = "present" }
  }
  
  file { "/etc/stunnel":
    ensure => directory;
  }
    
  service { 'stunnel':
    name => 'stunnel',
    enable => true,
    ensure => running,
    hasstatus => false;
  }
  
  if $use_nagios {
    case $nagios_stunnel_procs {
      'false': { info("We aren't doing nagios checks for stunnel on ${fqdn}" ) }
      default: { nagios::service { "stunnel": check_command => "nagios-stat-proc!/usr/bin/stunnel4!6!5!proc"; } }
    }
  }
}

class stunnel::linux inherits stunnel::base {
  
  if $stunnel_ensure_version == '' { $stunnel_ensure_version = 'installed' } 
  package { 'stunnel':
    ensure => $stunnel_ensure_version
  }
}    


class stunnel::debian inherits stunnel::linux {
  
  Package[stunnel] {
    name => 'stunnel4',
  }
  
  Service[stunnel] {
    name => 'stunnel4',
    pattern => '/usr/bin/stunnel4',
  }
  
  # make the /etc/default/stunnel configurable with a variable
  case $stunnel_startboot {
    '': { $stunnel_startboot = '1' }
  }
  
  file { '/etc/default/stunnel4':
    content => template("stunnel/Debian/default"),
    require => Package['stunnel4'],
    notify => Service['stunnel4'],
    owner => root, group => 0, mode => 0644;
  }
}

