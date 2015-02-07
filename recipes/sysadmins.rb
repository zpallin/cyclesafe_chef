
# include the sysadmins recipe
# don't install public keys and password hashes on vagrant machines
include_recipe 'users::sysadmins' do
  only_if { node[:instance_role] == 'vagrant' } 
end
