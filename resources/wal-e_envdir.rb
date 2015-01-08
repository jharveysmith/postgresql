actions :create, :delete

default_action :create

attribute :s3path,  kind_of: String
attribute :access,  kind_of: String
attribute :secret,  kind_of: String
attribute :path,    kind_of: String, name_attribute: true, required: true
attribute :user,    kind_of: String
attribute :group,   kind_of: String
