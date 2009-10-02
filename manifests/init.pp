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
# 2. stunnel::config allows you to configure the general stunnel configuration
#    e.g. stunnel::config { configdir => '/etc/stunnel4', enable => false }
# 3. stunnel::client allows you to configure different /etc/stunnel/*.conf files
#    to provide various stunnel configurations

# TODO: warn on cert/key issues, fail on false accept?

class stunnel {

  case $operatingsystem {
    debian: { include stunnel::debian }
    default: { include stunnel::default }
  }

  define client ( $ensure = present, $accept = false, $CApath = false, $CAfile = false,
                  $cert = false, $ciphers = false, $client = false, $connect = false,
                  $CRLpath = false, $CRLfile = false, $delay = false, $engineNum = false,
                  $exec = false, $execargs = false, $failover = false, $ident = false,
                  $key = false, $local = false, $OSCP = false, $OCSPflag = false,
                  $options = false, $pid = false, $protocol = false,
                  $protocolAuthentication = false, $protocolHost = false,
                  $protocolPassword = false, $protocolUsername = false, $pty = false,
                  $retry = false, $session = false, $sslVersion = "SSLv3",
                  $stack = false, $TIMEOUTbusy = false, $TIMEOUTclose = false,
                  $TIMEOUTconnect = false, $TIMEOUTidle = false, $transparent = false,
                  $verify = false ) {

    real_client = $client ? { default => "yes" }
    real_pid = $pid ? { false => "/${name}.pid", default => $pid }
                    
    file { "/etc/stunnel/${name}.conf":
      ensure => $ensure,
      content => template('stunnel/client.conf.erb'), 
      owner => root, group => 0, mode => 0600,
      require => File["/etc/stunnel"],
      notify => Service[stunnel];
    }
  }
}

class stunnel::config {
  
  $chroot = $chroot_override ? {
    '' => "/var/lib/stunnel4",
    default => $chroot_override
  }
  
  $compression = $compression_override ? {
    '' => false,
    default => $compression_override
  }
  
  $debuglevel = $debuglevel_override ? {
    '' => false,
    default => $debuglevel_override
  }
  
  $EGD = $EGD_override ? {
    '' => false,
    default => $EGD_override
  }
  
  $engine = $engine_override ? {
    '' => false,
    default => $engine_override
  }
  
  $engineCtrl = $engineCtrl_override ? {
    '' => false,
    default => $engineCtrl_override
  }
  
  $output = $output_override ? {
    '' => false,
    default => $output_override
  }
  
  $RNDbytes = $RNDbytes_override ? {
    '' => false,
    default => $RNDbytes_override
  }
  
  $RNDfile = $RNDfile_override ? {
    '' => false,
    default => $RNDfile_override
  }
  
  $RNDoverwrite = $RNDoverwrite_override ? {
    '' => false,
    default => $RNDoverwrite_override
  }
  
  $service = $service_override ? {
    '' => false,
    default => $service_override
  }
  
  $setuid = $setuid_override ? {
    '' => "stunnel4",
    default => $setuid_override
  }
  
  $setgid = $setgid_override ? {
    '' => "stunnel4",
    default => $setgid_override
  }
  
  $socket = $socket_override ? {
    '' => [ "l:TCP_NODELAY=1", "r:TCP_NODELAY=1" ],
    default => $socket_override
  }
  
  $syslog = $syslog_override ? {
    '' => false,
    default => $syslog_override
  }
}

class stunnel::base inherits stunnel::config {
  
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

