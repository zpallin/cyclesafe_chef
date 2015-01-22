#
# Cookbook Name:: cyclesafe_chef
# Recipe:: default
#

package 'git'
package 'libmysqlclient-dev'

include_recipe 'apt'
include_recipe 'runit'
include_recipe 'python'

# add cyclesafe user
user node[:cyclesafe_chef][:user] do
  system true
  shell '/bin/bash'
  home node[:cyclesafe_chef][:directory]
end
