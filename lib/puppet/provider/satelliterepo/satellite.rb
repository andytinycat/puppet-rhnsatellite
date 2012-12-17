# This is the only provider for the rhnrepo type.

require "xmlrpc/client"

Puppet::Type.type(:satelliterepo).provide :satellite, :parent => Puppet::Provider do

  defaultfor :operatingsystem => :RedHat

  desc "Uses the XMLRPC API of RHN Satellite to manage channel subscriptions."

  def create
    subscribe_to_channel(@resource[:channel])
  end

  def destroy
    unsubscribe_from_channel(@resource[:channel])
  end

  def exists?
    channel_subscribed_to?(@resource[:channel])
  end

  # Subscribe to a given channel using the up2date API
  def subscribe_to_channel(channel)

    details = read_server_conf()
    client = XMLRPC::Client.new2(details[:server])

    # Enable SSL certificate verification; we don't want to login to some other Satellite server!
    client.instance_variable_get("@http").verify_mode = OpenSSL::SSL::VERIFY_PEER
    client.instance_variable_get("@http").ca_file = "/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT"

    # Get systemid; up2date API uses this to auth a client
    systemid = read_systemid

    # Call API and subscribe us to a channel
    client.call("up2date.subscribeChannels", systemid, [channel], details[:username], details[:password])

  end

  def unsubscribe_from_channel(channel)

    details = read_server_conf()
    client = XMLRPC::Client.new2(details[:server])

    # Enable SSL certificate verification; we don't want to login to some other Satellite server!
    client.instance_variable_get("@http").verify_mode = OpenSSL::SSL::VERIFY_PEER
    client.instance_variable_get("@http").ca_file = "/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT"

    # Get systemid; up2date API uses this to auth a client
    systemid = read_systemid

    # Call API and unsubscribe us from a channel
    client.call("up2date.unsubscribeChannels", systemid, [channel], details[:username], details[:password])

  end

  def channel_subscribed_to?(channel)

    channel_labels = list_channels()
    channel_labels.each {|subscribed_channel|
      return true if channel == subscribed_channel
    }
    false

  end

  def list_channels

    details = read_server_conf()
    client = XMLRPC::Client.new2(details[:server])

    # Enable SSL certificate verification; we don't want to login to some other Satellite server!
    client.instance_variable_get("@http").verify_mode = OpenSSL::SSL::VERIFY_PEER
    client.instance_variable_get("@http").ca_file = "/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT"

    systemid = read_systemid

    channel_array = client.call("up2date.listChannels", systemid)

    channel_labels = []

    channel_array.each {|channel|
      channel_labels << channel['label']
    }

    channel_labels

  end

  def read_systemid
    File.read "/etc/sysconfig/rhn/systemid"
  end

  def read_server_conf

    server = ""
    username = ""
    password = ""
    organisation = ""
    system_type = ""

    # Read server URL, username, password from a file
    begin
      rhn_conf = File.new("/etc/puppet/rhn.conf", "r")
      while (line = rhn_conf.gets)
        line.gsub!(/[ \t]+/, " "); # blow away extra spaces/tabs
        next if line =~ /^#/;
        if line =~ /server = (\S+)/
          server = $1
        end
        if line =~ /username = (\S+)/
          username = $1
        end
        if line =~ /password = (\S+)/
          password = $1
        end
        if line =~ /organisation = (\S+)/
          organisation = $1
        end
        if line =~ /system_type = (\S+)/
          system_type = $1
        end
      end

      # Return the details to the caller
      {:server => server, :username => username, :password => password, :organisation => organisation, :system_type => system_type}

    rescue Exception => e
      raise IOError, "Couldn't access /etc/puppet/rhn.conf: #{e.message}"
    end

  end

end
