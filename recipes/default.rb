#
# Cookbook Name:: oraclexe
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Prevent ORACLE_HOME from having trailing slash
# see: http://www.dba-oracle.com/sf_ora_27101_shared_memory_realm_does_not_exist.htm
oracleHome = "#{Pathname.new(node['oraclexe']['oracle-home']).cleanpath}"

# set up environment variables
magic_shell_environment 'ORACLE_HOME' do
  value oracleHome
end
magic_shell_environment 'ORACLE_SID' do
  value node['oraclexe']['oracle-sid']
end
magic_shell_environment 'PATH' do
  value "#{File.join(node['oraclexe']['oracle-home'], 'bin')}:#{ENV['PATH']}"
end

# install some tools
%w{libaio bc initscripts net-tools wget}.each do | pkg |
  package pkg do
    action :install
  end
end

# Using wget since remote_file does not work well with e.g. Dropbox
# See https://github.com/chef/chef/issues/3474
bash "wget #{node['oraclexe']['url']}" do
  cwd "#{Chef::Config[:file_cache_path]}"
  code <<-EOH
wget #{node['oraclexe']['url']}
  EOH
end

rpmFile = File.join(Chef::Config[:file_cache_path], File.basename(node['oraclexe']['url']))

yum_package "install Oracle XE from #{rpmFile}" do
  source rpmFile
  action :install
end

# Preventing "Starting Oracle Net Listener...touch: cannot touch `/var/lock/subsys/listener': No such file or directory"
directory '/run/lock/subsys' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Overrrides default files in order to comment out memory_target preventing "ORA-00845: MEMORY_TARGET not supported on this system"
# see https://github.com/madhead/docker-oracle-xe
cookbook_file File.join(node['oraclexe']['oracle-home'], 'config/scripts/init.ora') do
  source 'init.ora'
  owner 'oracle'
  group 'dba'
  mode '0755'
  action :create
end
cookbook_file File.join(node['oraclexe']['oracle-home'], 'config/scripts/initXETemp.ora') do
  source 'initXETemp.ora'
  owner 'oracle'
  group 'dba'
  mode '0755'
  action :create
end

# Creates response file for configuration step
rspfile = File.join(node['oraclexe']['oracle-home'], 'config/scripts/xe.rsp')
template rspfile do
  source 'xe.rsp.erb'
  owner 'oracle'
  group 'dba'
  mode '0755'
  action :create
end

# Docker start script
cookbook_file '/start_oracle.sh' do
  source 'start_oracle.sh'
  mode '0755'
  action :create
end

execute 'configure via response file' do
  command "/etc/init.d/oracle-xe configure responseFile=#{rspfile}"
  creates '/u01/app/oracle/oradata'
end
