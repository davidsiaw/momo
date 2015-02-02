require 'aws-sdk-core'

module Momo
	class VPC
		def initialize
		end

		def type
			:vpc
		end

		def declare(resolver, name, options={})
			{
				cidr_block: options[:cidr_block],
				instance_tenancy: options[:instance_tenancy]
			}
		end

		def create(aws, structure, obj)
			result = aws.ec2.create_vpc(
				cidr_block: obj[:cidr_block],
				instance_tenancy: "default")

			result[:vpc][:vpc_id]
		end

		def modify(aws, structure, obj, id, options)

		end

		def delete(aws, structure, obj, id)
			aws.ec2.delete_vpc(
				vpc_id: id
				)
		end
	end

	MomoCloud.register_resource(VPC.new)

end

