require 'aws-sdk-core'

module Momo
	class SecurityGroup
		def initialize
		end

		def type
			:security_group
		end

		def declare(resolver, name, options={})
			{
				vpc: resolver.dependency(options[:vpc], :vpc),
				allow_in: options[:allow_in],
				allow_out: options[:allow_out],
			}
		end

		def create(aws, structure, obj)
			result = aws.ec2.create_security_group(
				group_name: obj[:name],
				description: obj[:name],
				vpc_id: structure[:started][obj[:vpc]],
			)

			id = result[:group_id]

			obj[:allow_in].each do |rule|

				options = rule.clone
				options[:group_id] = id
				aws.ec2.authorize_security_group_ingress(options)
			end

			obj[:allow_out].each do |rule|

				options = rule.clone
				options[:group_id] = id
				#pp options
				#aws.ec2.authorize_security_group_egress(options)
			end

			return id
		end

		def modify(aws, structure, obj, id, options)

		end

		def delete(aws, structure, obj, id)

			obj[:allow_in].each do |rule|

				options = rule.clone
				options[:group_id] = id
				aws.ec2.revoke_security_group_ingress(options)
			end

			obj[:allow_out].each do |rule|

				options = rule.clone
				options[:group_id] = id
				#aws.ec2.revoke_security_group_egress(options)
			end

			aws.ec2.delete_security_group(
				group_id: id)
		end
	end

	MomoCloud.register_resource(SecurityGroup.new)
end


