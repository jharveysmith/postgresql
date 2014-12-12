#
# Cookbook Name:: postgresql
# Recipe:: wal-e

# only install the wal-e entry if we have archive mode turned on and wal-e enabled
if node['postgresql']['wal_e']['enabled']
  Chef::Log.info("install wal-e postgres log shipper")

  missing_attrs = %w{
    aws_access_key
    aws_secret_key
    s3_bucket
  }.select do |attr|
    node['postgresql']['wal_e'][attr].nil?
  end.map { |attr| "node['postgresql']['wal_e']['#{attr}']" }

  if missing_attrs.any?
    Chef::Application.fatal!( "You must set #{missing_attrs.join(', ')}.")
  end

  # Save these in variables.
  myuser  = node['postgresql']['wal_e']['user']
  mygroup = node['postgresql']['wal_e']['group']

  # This is needed for wal-e even with postgres version 9.1
  # This recipe doesn't normally pull it unless postgres is greater then 9.1
  if platform_family?('ubuntu', 'debian')
    include_recipe 'postgresql::apt_pgdg_postgresql'
  end

  #install packages

  Array(node['postgresql']['wal_e']['packages']).each do |pkg|
    Chef::Log.debug("Install #{pkg} for wal-e recipe")
    package pkg
  end


  #install python modules with pip unless overriden
  unless node['postgresql']['wal_e']['pips'].nil?
    include_recipe "python::pip"
    node['postgresql']['wal_e']['pips'].each do |pip|
      Chef::Log.debug("Install pip #{pp} for wal-e recipe")
      python_pip pip
    end
  end

  code_path = "#{Chef::Config[:file_cache_path]}/wal-e"

  bash "install_wal_e" do
    cwd code_path
    code <<-EOH
      /usr/bin/python ./setup.py install
    EOH
    action :nothing
  end

  git code_path do
    repository "https://github.com/wal-e/wal-e.git"
    revision node['postgresql']['wal_e']['git_version']
    notifies :run, "bash[install_wal_e]"
  end

  postgresql_wal-e_envdir "#{node['postgresql']['wal_e']['env_dir']}" do
    user    myuser
    group   mygroup
  end

end
