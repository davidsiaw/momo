require 'aws-sdk-core'

module Momo
	class Gateway
		def initialize
		end

		def type
			:gateway
		end

		def declare(resolver, name, options={})
			{
				vpc: resolver.dependency(options[:vpc], :vpc)
			}
		end

		def create(aws, structure, obj)
			gateway_result = aws.ec2.create_internet_gateway()
			id = gateway_result[:internet_gateway][:internet_gateway_id]

			aws.ec2.attach_internet_gateway(
				internet_gateway_id: id,
				vpc_id: structure[:started][obj[:vpc]])

			return id
		end

		def modify(aws, structure, obj, id, options)

		end

		def delete(aws, structure, obj, id)

			aws.ec2.detach_internet_gateway(
				internet_gateway_id: id,
				vpc_id: structure[:started][obj[:vpc]])

			aws.ec2.delete_internet_gateway(
				internet_gateway_id: id)
		end
	end
	
	MomoCloud.register_resource(Gateway.new)

end

