class stunnel::linux inherits stunnel::base {
  
  if $stunnel_ensure_version == '' { $stunnel_ensure_version = 'installed' } 
  package { 'stunnel':
    ensure => $stunnel_ensure_version
  }
}    
