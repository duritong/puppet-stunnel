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

  define client ( $ensure = present, $accept = false, $CApath = false,
                  $CAfile = false, $cert = false, $chroot = false,
                  $ciphers = false, $client = false, $compress =
                  false, $connect = false, $CRLpath = false, $CRLfile
                  = false, $debuglevel = false, $delay = false, $EGD =
                  false, $engine = false, $engineCtrl = false,
                  $engineNum = false, $exec = false, $execargs =
                  false, $failover = false, $ident = false, $key =
                  false, $local = false, $OSCP = false, $OCSPflag =
                  false, $options = false, $output = false, $pid =
                  false, $protocol = false, $protocolAuthentication =
                  false, $protocolHost = false, $protocolPassword =
                  false, $protocolUsername = false, $pty = false,
                  $retry = false, $RNDbytes = false, $RNDfile = false,
                  $RNDoverwrite = false, $service = false, $session =
                  false, $setuid = "stunnel4", $setgid = "stunnel4",
                  $socket = [ "l:TCP_NODELAY=1, "r:TCP_NODELAY=1"],
                  $sslVersion = "SSLv3", $stack = false, $syslog =
                  false, $TIMEOUTbusy = false, $TIMEOUTclose = false,
                  $TIMEOUTconnect = false, $TIMEOUTidle = false,
                  $transparent = false, $verify = false ) {

    $real_client = $client ? { default => "yes" }
    $real_pid = $pid ? { false => "/${name}.pid", default => $pid }
                    
    file { "/etc/stunnel/${name}.conf":
      ensure => $ensure,
      content => template('stunnel/client.conf.erb'), 
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
    hasstatus => false,
    require => File["/etc/stunnel/stunnel.conf"];
  }
  
  if $use_nagios {
    case $nagios_stunnel_procs {
      'false': { info("We aren't doing nagios checks for stunnel on ${fqdn}" ) }
      default: { nagios::service { "stunnel": check_command => "nagios-stat-proc!/usr/bin/stunnel4 /etc/stunnel/stunnel.conf!6!5!proc"; } }
    }
  }
}

class stunnel::linux inherits stunnel::base {
  
  if $stunnel_ensure_version == '' { $stunnel_ensure_version = 'installed' } 
  package { 'stunnel':
    ensure => $stunnel_ensure_version
  }
  File[stunnel_config]{
    require => Package[stunnel]
  }
}    


class stunnel::debian inherits stunnel::linux {
  
  Package[stunnel] {
    name => 'stunnel4',
  }
  
  Service[stunnel] {
    name => 'stunnel4',
    pattern => '/usr/bin/stunnel4 /etc/stunnel/stunnel.conf',
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

