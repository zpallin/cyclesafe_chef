#
# Cookbook Name:: cyclesafe_chef
# Recipe:: default
#

# absolutely necessary for running programs
include_recipe 'apt'

# include git because magically it's not installed
package 'git'

# mysql on ubuntu relies on this package, as well as a apt-get update being run on the OS before mysql and the django-mysql plugin can be used
package 'libmysqlclient-dev' do
  notifies :run, 'execute[apt-get update]', :immediately
end

# add cyclesafe user
user node[:cyclesafe_chef][:user] do
  system true
  shell '/bin/bash'
  home node[:cyclesafe_chef][:directory]
end
