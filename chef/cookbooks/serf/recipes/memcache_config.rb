cookbook_file '/usr/local/bin/memcache_from_serf.rb' do
  mode '0755'
  owner 'root'
  group 'root'
  notifies :restart, 'runit_service[memcache_config]'
end

runit_service 'memcache_config'

