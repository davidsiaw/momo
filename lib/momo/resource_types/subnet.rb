require 'aws-sdk-core'

module Momo
	class Subnet
		def initialize
		end

		def type
			:subnet
		end

		def declare(resolver, name, options={})
			{
				vpc: resolver.dependency(options[:vpc], :vpc),
				cidr_block: options[:cidr_block],
				availability_zone: options[:availability_zone]
			}

		end

		def create(aws, structure, obj)
			result = aws.ec2.create_subnet(
				vpc_id: structure[:started][obj[:vpc]],
				cidr_block: obj[:cidr_block],
				availability_zone: obj[:availability_zone])

			return result[:subnet][:subnet_id]
		end

		def modify(aws, structure, obj, id, options)

		end

		def delete(aws, structure, obj, id)
			aws.ec2.delete_subnet(
				subnet_id: id)
		end
	end
	
	MomoCloud.register_resource(Subnet.new)

end

