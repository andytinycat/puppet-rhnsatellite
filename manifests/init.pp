# == Class: puppet-rhnsatellite
#
# This module contains a provider and type to manage RHN Satellite channels.
#
# === Parameters
#
# [*server_url*]
#   URL to the XMLRPC endpoint of the Satellite server. Normally:
#   https://rhn.your.org/XMLRPC
#
# [*username*]
#   Username of a RHN Satellite administrator; required so the module can
#   change a client machine's subscriptions.
#
# [*password*]
#   Password for the above user.
#
# [*ssl_cert*]
#   Name of the SSL certificate your RHN Satellite server will present. Place
#   this file in the 'files' directory of this module with the .pem extension.
#
# === Examples
#
#  class { 'puppet-rhnsatellite':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Andy Sykes <andy@tinycat.co.uk>
#
# === Copyright
#
# Copyright 2012 Andy Sykes, unless otherwise noted.
#
class puppet-rhnsatellite(
  $server_url  = "http://rhn.redhat.com/XMLRPC",
  $username = "orgadmin",
  $password = "password"
) {

  # Read by the provider on the machine, to log into RHN and
  # change subscriptions.
  file {'/etc/puppet/rhn.conf':
    owner   => root,
    group   => root,
    mode    => 0600,
    content => template('puppet-rhnsatellite/rhn.conf.erb')
  }

}
