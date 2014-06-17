# This is just some random default key
default.serf.encrypt_key = 'my2QGv0gmoFQxh5suQaTSg=='
#if node['env'] != 'dev'
#  serf_secrets = Chef::EncryptedDataBagItem.load('serf', node['env'])
#  default.serf.encrypt_key = serf_secrets['key'] || "-"
#end

# Shasum (version)
default.serf.shasum = "e1be5b4f7bcf"

# Expecting a masters list
default.serf.masters = [ '192.168.33.11', '192.168.33.12' ]

default.serf.config = {
  node_name: node.hostname,
  start_join: node.serf.masters,
  encrypt_key: node.serf.encrypt_key,
  bind: node.ipaddress,
  profile: 'lan',
  snapshot_path: '/dev/shm/serf_workfile',
  tags: {},
  event_handlers: [],
}

# Now let's check if the bind IP address is correct!
if node.ipaddress =~ /(^127\.0\.0\.1)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/
  # private ip

  # are we in Vagrant?
  if node.filesystem.has_key? '/vagrant'
    if node.network.interfaces.has_key? 'eth1'
      ad = node.network.interfaces.eth1.addresses
      # take the first ipv4 from that list
      ad.keys.each do |tryip|
        if tryip =~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/
          default.serf.config.bind = tryip
          break
        end
      end
    end
  else     

    # so we're not in Vagrant. Let's see if we're on EC2. Getting this directly with curl.
    node.default.ec2 = {} unless node.has_key? 'ec2'

    # let's try if I get something from curl
    ip=`curl -s --connect-timeout 2 --retry 1 http://169.254.169.254/latest/meta-data/public-ipv4`
    if ip =~ /^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$/
      node.serf.config.advertise = ip
    end
  end
end

# Some Airbnb/Stemcell style Stuff
if File.exists? '/etc/chef/role' and File.exists? '/etc/chef/branch'

  default.serf.config.tags.chef_role   = File.read('/etc/chef/role').strip
  default.serf.config.tags.chef_branch = File.read('/etc/chef/branch').strip
  default.serf.config.tags.codename = node['lsb']['codename'] if node['lsb']['codename']
end

# Serf members.json callback
default.serf.config.event_handlers <<
  "member-join,member-leave,member-failed,member-update=serf members -format json "+
  "> /dev/shm/serf_members.json.$$ && mv /dev/shm/serf_members.json.$$ /dev/shm/serf_members.json"

