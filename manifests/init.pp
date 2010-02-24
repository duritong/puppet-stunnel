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

  case $stunnel_ensure_version {
    '': { $stunnel_ensure_version = "present" }
  }

  case $operatingsystem {
    debian: { include stunnel::debian }
    default: { include stunnel::default }
  }

  if $use_nagios {
    case $nagios_stunnel_procs {
      'false': { info("We aren't doing nagios checks for stunnel on ${fqdn}" ) }
      default: { nagios::service { "stunnel": check_command => "nagios-stat-proc!/usr/bin/stunnel4!6!5!proc"; } }
    }
  }
}
