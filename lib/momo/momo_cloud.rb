require 'aws-sdk-core'
require 'yaml'
require 'active_support/all'

module Momo
	class MomoCloud

		class Resolver
			def initialize(structure)
				@resources = structure[:resources]
				@dependencies = {}
			end

			def get_resource_by_name(name)
				@resources[name]
			end

			def dependency(item, should_be_type = nil)

				resolved_item = nil

				if item.is_a?(String)
					if @resources.has_key? item
						resolved_item = @resources[item]
					end
				elsif item.has_key?(:type)
					if should_be_type and item[:type] == should_be_type
						resolved_item = item
					elsif !should_be_type
						resolved_item = item
					end
				end

				if resolved_item
					@dependencies[resolved_item[:name]] = {
						type: resolved_item[:type]
					}
					return resolved_item[:name]
				end

				raise "Invalid item: #{item.inspect}"
			end

			def deps
				return @dependencies
			end
		end

		@@types = {}

		def self.register_resource(resource)
			@@types[resource.type] = resource
		end

		def initialize(config, &block)
			@config = config
			@structure = {
				region: "ap-northeast-1",
				resources: {},
				order: [],
				started: {}
			}
			instance_eval(&block) if block
			raise "Nothing to create" unless block
		end

		def method_missing(method, *arg)
			name = arg[0]
			options = arg[1]

			resolver = Resolver.new(@structure)

			if @@types.has_key? method
				res = @@types[method].declare(resolver, name, options)
				res[:name] = name
				res[:type] = method
				@structure[:resources][name] = res

				@structure[:order] << res
				return res
			else
				raise "Resource Type '#{method}' not found" 
			end
		end

		def region (region)
			@structure[:region] = region
		end

		def _setstructure (structure)
			@structure = structure
		end

		def structure
			@structure
		end

		def availability_zones
			aws = MomoAws.new(@structure[:region])
			aws.availability_zones
		end

		def create
			aws = MomoAws.new(@structure[:region])

			@structure[:order].each do |x|
				id = @@types[x[:type]].create aws, @structure, x
				@structure[:started][x[:name]] = id
			end
		end

		def modify
		end

		def delete
			aws = MomoAws.new(@structure[:region])

			@structure[:order].reverse.each do |x|
				@@types[x[:type]].delete aws, @structure, x, @structure[:started][x[:name]]
				@structure[:started].except!(x[:name])
			end
		end
	end
end
