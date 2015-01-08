def whyrun_supported?
  true
end

action :create do
  if new_resource.exists?
    Chef::Log.info("'#{new_resource}' already exists, nothing to do.")
  else
    converge_by("Create #{new_resource}") do
      create_envdir
    end
  end
end

action :delete do
  if new_resource.exists?
    converge_by("Remove #{new_resource}") do
      file new_resource.path do #~FC009
        action :delete
        recursive true
      end
    end
  else
    Chef::Log.info("'#{new_resource}' doesn't exist, nothing to do.")
  end
end


def create_envdir
  mypath = new_resource.path
  access = new_resource.access || node['postgresql']['wal_e']['aws_access_key']
  secret = new_resource.secret || node['postgresql']['wal_e']['aws_secret_key']
  s3path = case
    when new_resource.s3path
      new_resource.s3path
    when (node['postgresql']['wal_e']['s3_path'] || '') =~ /^[sS]3:/
      node['postgresql']['wal_e']['s3_path']
    when node['postgresql']['wal_e']['s3_path']
      "s3://" + node['postgresql']['wal_e']['s3_path']
    else
      "s3://#{node['postgresql']['wal_e']['s3_bucket']}/#{node['postgresql']['wal_e']['bkp_folder']}"
    end
  myuser  = node['postgresql']['wal_e']['user']
  mygroup = node['postgresql']['wal_e']['group']

  vars = {
    'AWS_ACCESS_KEY_ID'     => access,
    'AWS_SECRET_ACCESS_KEY' => secret,
    'WALE_S3_PREFIX'        => s3path
  }

  directory mypath do
    user    myuser
    group   mygroup
    mode    "0550"
  end

  vars.each do |key, value|
    file ::File.join(mypath,key) do
      content value
      user    myuser
      group   mygroup
      mode    "0440"
    end
  end
end
