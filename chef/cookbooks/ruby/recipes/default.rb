if node.lsb.codename == 'precise'

  apt_repository 'brightbox-ruby-ng' do
    uri 'http://ppa.launchpad.net/brightbox/ruby-ng/' + node['platform']
    keyserver 'keyserver.ubuntu.com'
    key 'C3173AA6'
    distribution node['lsb']['codename']
    components ['main']
  end

  %w[ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 build-essential
    libopenssl-ruby1.9.1 libssl-dev zlib1g-dev
  ].each do |p|
    package p do
      action :upgrade
    end
  end

  %w[ruby irb gem].each do |name|
    link "/usr/bin/#{name}" do
      user 'root'
      group 'root'
      to name + '1.9.1'
      not_if { File.exists? "/usr/bin/#{name}" and !(File.symlink? "/usr/bin/#{name}") }
    end
  end

else

  package 'ruby1.9.3'

end

