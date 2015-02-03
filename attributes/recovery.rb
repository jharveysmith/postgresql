# env_dir: /etc/recovery_env.d
# s3path: s3path from which to recover
# All values are single quoted by the template.
default['postgresql']['recovery'] = {
  wal_e: false,
  base_backup_target: "LATEST",
  config: {
    "#restore_command"            => " ''           # e.g. 'cp /mnt/server/archivedir/%f %p'",
    "#archive_cleanup_command"    => "''",
    "#recovery_end_command"       => "''",
    "#recovery_target_name"       => "''      # e.g. 'daily backup 2011-01-26'",
    "#recovery_target_time"       => "''      # e.g. '2004-07-14 22:39:00 EST'",
    "#recovery_target_xid"        => "''",
    "#recovery_target_inclusive"  => "true",
    "#recovery_target_timeline"   => "'latest'",
    "#pause_at_recovery_target"   => "true",
    "#standby_mode"               => "off",
    "#primary_conninfo"           => "''          # e.g. 'host=localhost port=5432'",
    "#trigger_file"               => "''"
  }
}
