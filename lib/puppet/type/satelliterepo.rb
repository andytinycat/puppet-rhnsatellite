# This is a custom Puppet type for managing repos provided by RHN Satellite.

Puppet::Type.newtype(:satelliterepo) do
  @doc = "Manage a repo provided by RHN Satellite."

  ensurable

  newparam(:channel, :namevar => true) do
    desc "The name of the channel to subscribe to."
  end

  autorequire(:file) do
    ['/etc/puppet/rhn.conf']
  end

end
