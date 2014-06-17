#!/usr/bin/env ruby

require 'json'
require 'fileutils'

last_data  = ''
source     = '/dev/shm/serf_members.json'
dest       = '/dev/shm/memcache_servers.json'
last_ctime = 0
last_discover = 0
search_tag = 'smart:memcache_11211'

# There is an edge case here:
# say that there have been several changes in the network in the last seconds,
# such as a massive rejoin after a network partition.
# The software might pick up a file dated from the beginning of the second and 
# it might then be updated at the end of the second, and it wouldn't be noticed
# by stat(2) because it only does second timestamps
#
# So I gave it some thought and came up with something: enforce doing a reread
# ten seconds later


# Simplicity: no exception control: just die and get restarted by runit.

loop do
  ctime = File.stat(source).ctime.to_i

  if ctime > last_ctime or (last_discover < ctime + 10 and Time.new.to_i > ctime + 10)
    last_ctime = ctime
    last_discover = Time.new.to_i
    calc_data = []

    serfmembers = JSON.load(File.read(source))
    members = serfmembers['members']
    members.each do |member|
      next unless member['status'] == 'alive'
      member['tags'].each do |tag,data|
        if tag == search_tag
          host,port = data.split ':'
          calc_data << { host: host, port: port }
        end
      end
    end

    next if calc_data.length == 0

    calc_data.sort! {|a,b| a.to_s <=> b.to_s }

    if calc_data.to_s != last_data
      File.write("#{dest}.tmp", JSON.generate(calc_data))
      FileUtils.mv "#{dest}.tmp", dest
      last_data = calc_data.to_s
    end
  end
  sleep 1
end
