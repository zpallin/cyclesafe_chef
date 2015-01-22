name             'cyclesafe_chef'
maintainer       'CycleSafe'
maintainer_email 'zpallin@gmail.com'
license          'All rights reserved'
description      'Installs/Configures cyclesafe_chef'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.3'

unless defined?(Ridley::Chef::Cookbook::Metadata)
  source_url       'https://github.com/zpallin/cyclesafe_chef.git'
end

depends 'application'
depends 'application_python'
depends 'application_nginx'
depends 'database'
depends 'nginx'
depends 'logrotate'
depends 'poise'
depends 'python'
depends 'runit'
depends 'sqlite'
depends 'users'
