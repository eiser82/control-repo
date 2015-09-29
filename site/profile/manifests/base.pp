class profile::base {
  class { '::ntp':
    servers => [ '2.us.pool.ntp.org', '3.us.pool.ntp.org']
  }
}
