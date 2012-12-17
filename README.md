puppet-rhnsatellite
===================

This is a very simple provider and type that allow you control what channels
a RHEL machine is subscribed to; these channels can be provided by your local
Satellite server, or from RHN.

Precursors
----------

Your machine already needs to be registered with RHN or with Satellite. At the
site where a version of this code is used, machines are registered on provisioning.

How it works
------------

The provider makes use of the undocumented Red Hat up2date API for controlling
the channel subscriptions of an individual machine. For some reason, this API
is used by the `spacewalk-channel` command, but is not exposed in the API
documentation. I figured out how to use the API by reading the source for
`spacewalk-channel`; it's all Python, after all.

The module requires an org admin username and password. It needs this so it can
change the subscriptions on machines inside your Satellite org. It writes a file
at /etc/puppet/rhn.conf with this information, which the provider uses on
subsequent invocations.

I did it like this so you could use the `satelliterepo` type very similarly to
the `yumrepo` type; otherwise you'd have had to specify the admin username and
password all over your manifests.

Example
-------

Simply include the module into your manifest:

`class {'puppet-rhnsatellite':
  server  => 'https://your.server.here/XMLRPC',
  username => 'bob',
  password => 'bob'
}`

Now you can subscribe to channels anywhere in that machine's manifest by doing:

`satelliterepo {channel => 'some-rhn-channel-label'}`
