name             'cyclesafe_chef'
maintainer       'CycleSafe'
maintainer_email 'zpallin@gmail.com'
license          'All rights reserved'
description      'Installs/Configures cyclesafe_chef'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

unless defined?(Ridley::Chef::Cookbook::Metadata)
  source_url       'https://github.com/zpallin/cyclesafe_chef.git'
end

depends 'application', '= 4.1.6'
depends 'application_python', '= 1.2.2'
depends 'application_nginx', '= 2.0.0'
depends 'apt', '= 2.6.1'
depends 'mysql', '= 1.3.0'
depends 'nginx', '= 2.7.4'
depends 'logrotate', '= 1.7.0'
depends 'poise', '= 1.0.10'
depends 'python', '= 1.4.7'
depends 'runit', '= 1.2.0'
depends 'sqlite', '= 1.1.0'
