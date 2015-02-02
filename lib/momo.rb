require "momo/version"
require 'aws-sdk-core'
require 'yaml'

require "momo/momo_config"
require "momo/momo_cloud"
require "momo/momo_aws"
require "momo/resource_types/all"

module Momo

end

def momo_create(&block)
	cloud = Momo::MomoCloud.new(Momo::MomoConfig.new, &block)
	cloud.create
	cloud.structure
end

def momo_modify(structure, &block)
	cloud = Momo::MomoCloud.new(Momo::MomoConfig.new, &block)
	cloud.modify
	cloud.structure
end

def momo_delete(structure)
	cloud = Momo::MomoCloud.new Momo::MomoConfig.new do
		_setstructure structure
	end
	cloud.delete
	cloud.structure
end
