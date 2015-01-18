
include_recipe 'cyclesafe_chef'

# install dependencies
package 'libffi-dev'

# assign secret_key value
secret_key = data_bag_item('keys','secret_key')['key']

# second secret_key escaped for supervisord pickiness!
secret_key_supervisord = "#{secret_key.gsub(/%/,'%%')}";

# add cyclesafe user
user 'cyclesafe' do
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

# setup gunicorn socket
sock_dir = "#{node[:cyclesafe_chef][:directory]}/run"

# gunicorn command attributes
app_name = 'cyclesafe'
django_dir = "#{node[:cyclesafe_chef][:directory]}/current"
sock_file = "#{sock_dir}/cyclesafe.sock"
shared_dir = "#{node[:cyclesafe_chef][:directory]}/shared/env/"
wsgi_module = 'cyclesafe'
settings_module = 'cyclesafe.settings'
log_level = node[:cyclesafe_chef][:log_level] || 'debug'
num_workers = 3

# app_module command
gunicorn_app_module = [
  "#{wsgi_module}:application",
  "--name #{app_name}",
  "--workers #{num_workers}",
  "--user=#{node[:cyclesafe_chef][:user]}",
  "--group=#{node[:cyclesafe_chef][:group]}",
  "--bind=unix:#{sock_file}",
  "--log-level=#{log_level}",
  "--log-file=-"
  ].join(' ')


# sock directory creation
directory sock_dir do
  action :create
  user node[:cyclesafe_chef][:user]
  group node[:cyclesafe_chef][:group]
  mode 0755
  recursive true
end

# install django
application 'cyclesafe' do
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
      password 'cyclesafe'
      host 'localhost'
      port 3306
    end

    database_master_role 'cyclesafe_database'
  end

  gunicorn do
    host 'cyclesafe.com'
    app_module 'cyclesafe.wsgi:application'
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

=begin
gunicorn_startup_django app_name do
  user node[:cyclesafe_chef][:user]
  group node[:cyclesafe_chef][:group]
  
  djangodir django_dir
  sockfile sock_file
  activate_path "#{node[:cyclesafe_chef][:directory]}/shared/env/bin/activate"
  gunicorn_path "#{node[:cyclesafe_chef][:directory]}/shared/env/bin/gunicorn"
end
=end

# hack supervisor file
=begin
supervisor_service app_name do
    action :enable
    command "cyclesafe_django"
    directory django_dir
    autostart false
    user node[:cyclesafe_chef][:user]
    environment ({"SECRET_KEY"=>secret_key_supervisord})
end
=end
