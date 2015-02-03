
# Cookbook Name:: postgresql
# Recipe:: wal-e_archive

# only install the wal-e entry if we have archive mode turned on and wal-e enabled
if node['postgresql']['config']['archive_mode'] && node['postgresql']['wal_e']['enabled']
  include_recipe 'postgresql::wal-e'
  Chef::Log.info("set up our wal-e shipper")

  # Save these in variables.
  myuser  = node['postgresql']['wal_e']['user']
  mygroup = node['postgresql']['wal_e']['group']

  # override our archive command
  node.default['postgresql']['config']['archive_command'] =
    "/usr/bin/envdir #{node['postgresql']['wal_e']['env_dir']} /usr/local/bin/wal-e wal-push %p"
  node.default['postgresql']['config']['archive_timeout'] = 60
  node.set['postgresql']['shared_archive'] = nil

  bb_cron = node['postgresql']['wal_e']['base_backup']
  if bb_cron

    cron_cmd = [
      bb_cron['flock_cmd'],   # This can be empty
      bb_cron['timeout_cmd'], # This can be empty
      # The cron command always contains the following.
      "/usr/bin/envdir",
      node['postgresql']['wal_e']['env_dir'],
      "/usr/local/bin/wal-e backup-push",
      node['postgresql']['config']['data_directory']
    ].join(' ').strip

    # If we want to log this, ensure the log dir exists.
    if bb_cron['log_path']
      directory bb_cron['log_path'] do
        user    myuser
        group   mygroup
        mode    "0755"
      end

      include_recipe 'logrotate'
      # Rotate the wal-e backup logs once a week, keep seven of them.
      logrotate_app 'wal_e-base-backup-logrotate' do
        cookbook  'logrotate'
        path      bb_cron['log_path']
        frequency 'weekly'
        rotate    7
        create    "644 #{myuser} #{mygroup}"
      end

      # Finally, append a redirect to the log to the end of the cron command.
      cron_cmd += " >> #{bb_cron['log_path']}/wal_e-base-backup.log 2>&1"
    end

    cron "wal_e_base_backup" do
      user    myuser
      command cron_cmd
      minute  bb_cron['minute']
      hour    bb_cron['hour']
      day     bb_cron['day']
      month   bb_cron['month']
      weekday bb_cron['weekday']
    end
  end

end
