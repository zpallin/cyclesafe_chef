
# include defaults
include_recipe 'cyclesafe_chef'

# install dependencies
package 'libffi-dev'

# assign secret_key value
secret_key = data_bag_item('keys','secret_key')['key']

# second secret_key escaped for supervisord pickiness!
secret_key_supervisord = "#{secret_key.gsub(/%/,'%%')}";

# easy variable references
sock_dir = "#{node[:cyclesafe_chef][:directory]}/run"
app_name = 'cyclesafe'
django_dir = "#{node[:cyclesafe_chef][:directory]}/current"
sock_file = "#{sock_dir}/#{app_name}.sock"
shared_dir = "#{node[:cyclesafe_chef][:directory]}/shared/env/"
wsgi_module = "#{app_name}.wsgi:application"
settings_module = "#{app_name}.settings"
log_level = node[:cyclesafe_chef][:log_level] || 'debug'
num_workers = 3

# add cyclesafe user
user node[:cyclesafe_chef][:user] do
  system true
  shell '/bin/bash'
  home node[:cyclesafe_chef][:directory]
end

# create shared directory
directory "#{node[:cyclesafe_chef][:directory]}/shared" do
  user node[:cyclesafe_chef][:user]
  group node[:cyclesafe_chef][:group]
  mode '0775'
  recursive true
end

# set environment variable
ENV['SECRET_KEY'] = secret_key

# sock directory creation
directory sock_dir do
  action :create
  user node[:cyclesafe_chef][:user]
  group node[:cyclesafe_chef][:group]
  mode 0755
  recursive true
end

# install django
application app_name do
  path node[:cyclesafe_chef][:directory]
  owner node[:cyclesafe_chef][:user]
  group node[:cyclesafe_chef][:group]
  repository 'https://github.com/zemadi/CycleSafe_deploy.git'
  revision 'master'
  migrate true
  rollback_on_error false

  django do
    requirements node[:cyclesafe_chef][:requirements_file]
    debug true
    packages ['gunicorn']
    settings_template 'settings.py.erb'
    
    database do
      database 'cyclesafe'
      adapter 'mysql'
      username 'cyclesafe'
      password data_bag_item('passwords','database')['mysql']
      host 'localhost'
      port 3306
    end

    database_master_role 'cyclesafe_database'
  end

  gunicorn do
    host 'cyclesafe.com'
    app_module wsgi_module
    socket_path sock_file
    autostart true
    virtualenv shared_dir
    environment ({"SECRET_KEY"=>secret_key_supervisord})
  end

  nginx_load_balancer do
    server_name 'cyclesafe.com'
    port 80
    application_socket ["#{sock_file} fail_timeout=0"]
    static_files '/static' => 'app/static'
  end
end
