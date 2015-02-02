require 'aws-sdk-core'

module Momo
	class RouteTable
		def initialize
		end

		def type
			:route_table
		end

		def declare(resolver, name, options={})
			result = {
				vpc: resolver.dependency(options[:vpc], :vpc),
				routes: {}
			}

			if options[:routes]
				options[:routes].each_pair do |name, cidr|
					resource = resolver.get_resource_by_name(resolver.dependency(name, nil))

					if resource[:type] == :gateway or 
						resource[:type] == :instance or
						resource[:type] == :network_interface or
						resource[:type] == :vpc_peering_connection
						result[:routes][resource[:name]] = cidr
					else
						raise "Cannot route to #{resource[:type]}"
					end
				end
			end

			return result
		end

		def create(aws, structure, obj)

			rt_result = aws.ec2.create_route_table(
			  vpc_id: structure[:started][obj[:vpc]],
			)

			id = rt_result[:route_table][:route_table_id]

			if obj[:routes]
				obj[:routes].each_pair do |name, cidr|
					resource = structure[:resources][name]
					object_id = structure[:started][name]

					options = {
						route_table_id: id,
						destination_cidr_block: cidr
					}
					options["#{resource[:type]}_id".to_sym] = object_id

					aws.ec2.create_route(options)
				end
			end

			return id

		end

		def modify(aws, structure, obj, id, options)

		end

		def delete(aws, structure, obj, id)

			if obj[:routes]
				obj[:routes].each_pair do |name, cidr|
					resource = structure[:resources][name]

					aws.ec2.delete_route(
						route_table_id: id,
						destination_cidr_block: cidr)
				end
			end

			aws.ec2.delete_route_table(
				route_table_id: id)

		end
	end

	MomoCloud.register_resource(RouteTable.new)

end

