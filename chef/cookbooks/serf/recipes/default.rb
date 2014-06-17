# SERF

include_recipe 'runit'

group 'smartstack'
user 'smartstack' do
  group 'smartstack'
  shell '/sbin/nologin'
  home '/opt/smartstack'
end

if node.kernel.machine == 'x86_64'
  remote_file "/usr/local/bin/serf_#{node.serf.shasum}" do
    source "https://s3-eu-west-1.amazonaws.com/artifacts.gyg/serf/serf_#{node.serf.shasum}"
    checksum node.serf.shasum
    mode '0750'
    owner 'root'
    group 'smartstack'
    notifies :run, 'execute[killall serf]'
  end

  link '/usr/bin/serf' do
    to "/usr/local/bin/serf_#{node.serf.shasum}"
  end

  Dir.glob("/usr/local/bin/serf*").each do |f|
    next if f == "/usr/local/bin/serf_#{node.serf.shasum}"
    file f do
      action :delete
      ignore_failure true
    end
  end

  #placeholder for if old machines are not 64bit
end

directory '/etc/serf' do
  mode '0775'
  owner 'root'
  group 'smartstack'
end

file '/etc/serf/aaa_chef_config.json' do
  mode '0640'
  owner 'root'
  group 'smartstack'
  content JSON.pretty_generate(node.serf.config)
  notifies :run, 'execute[reload serf]'
end

%w[chef_tags generic synapse].each do |f|
  file "/etc/serf/#{f}.json" do
    action :delete
    notifies :run, 'execute[reload serf]'
  end
end

execute 'reload serf' do
  command 'killall -HUP serf || true'
  action :nothing
end

execute 'killall serf' do
  command 'killall serf || true' # the ||true means it can fail
  action :nothing
end

runit_service 'serf'
