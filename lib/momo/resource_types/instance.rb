require 'aws-sdk-core'

module Momo
	class Instance
		def initialize
		end

		def type
			:instance
		end

		def declare(resolver, name, options={})
			{
			}
		end

		def create(aws, structure, obj)
		end

		def modify(aws, structure, obj, id, options)

		end

		def delete(aws, structure, obj, id)
		end
	end
	
	MomoCloud.register_resource(Instance.new)

end

