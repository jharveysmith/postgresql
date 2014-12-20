#
# Cookbook Name:: postgresql
# Recipe:: wal-e_recovery

# only install the wal-e entry if we have recovery mode turned on and wal-e enabled
if (node['postgresql']['recovery']||{})['wal_e'] && node['postgresql']['wal_e']['enabled']
  include_recipe 'wal-e'
  Chef::Log.info("Set up our wal-e based recovery file.")

  # Save these in variables.
  myuser  = node['postgresql']['recovery']['user'] ||
    node['postgresql']['wal_e']['user']
  mygroup = node['postgresql']['recovery']['group'] ||
    node['postgresql']['wal_e']['group']

  # Create our wal-e recover env_dir so it can be different
  # from where we write our own back up to.
  env_dir = node['postgresql']['recovery']['env_dir'] ||
    node['postgresql']['wal_e']['env_dir'] + "_recovery"

  postgresql_wal_e_endir env_dir do
    user  myuser
    group mygroup
    s3path node['postgresql']['recovery']['s3path']
  end

  recover_file = File.join(
    node['postgresql']['config']['data_directory'],
    "recovery.conf"
  )
  template recover_file do
    source "recovery.conf.erb"
    variables({
      config: {
        restore_command: "envdir #{env_dir} wal-e wal-fetch \"%f\" \"%p\""
      }.merge(node['postgresql']['recovery']['config'])
    })
    notifies :restart, 'service[postgresql]', :delayed
  end

end
