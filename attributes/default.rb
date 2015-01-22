
node.default[:cyclesafe_chef][:user] = 'cyclesafe'
node.default[:cyclesafe_chef][:group] = 'cyclesafe'
node.default[:cyclesafe_chef][:directory] = '/srv/cyclesafe'
node.default[:cyclesafe_chef][:requirements_file] = 'prod_requirements.txt'
node.default[:cyclesafe_chef][:repository] = 'https://github.com/zemadi/CycleSafe_deploy.git'
node.default[:cyclesafe_chef][:db_name] = 'default'
node.default[:cyclesafe_chef][:hostname] = 'cyclesafe.com'
