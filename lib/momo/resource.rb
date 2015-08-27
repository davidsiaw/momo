module Momo

	class Resource < MomoScope

		attr_accessor :type, :name, :props, :metadata, :dependencies

		def initialize(type, name)
			@type = type
			@name = name
			@metadata = nil
			@props = {}
			@dependencies = []
		end

		def method_missing(name, *args, &block)

			if /^[[:upper:]]/.match(name) == nil
				raise "Invalid resource name: #{name}"
			end

			@props[name] = Momo.resolve(args[0])
		end

		def init_metadata!

			if !@metadata 
				@metadata = {}
			end
		end

		def init_cfinit!
			init_metadata!
			
			if !@metadata["AWS::CloudFormation::Init"]
				@metadata["AWS::CloudFormation::Init"] = {}
			end
				 
			if !@metadata["AWS::CloudFormation::Init"]["config"]
				@metadata["AWS::CloudFormation::Init"]["config"] = {
					"packages" => {},
					"groups" => {},
					"users" => {},
					"sources" => {},
					"files" => {},
					"commands" => {},
					"services" => {}
				}
			end
		end

		def init_group(group)
			init_cfinit!
			if !@metadata["AWS::CloudFormation::Init"]["config"][group] 
				@metadata["AWS::CloudFormation::Init"]["config"][group] = {}
			end
		end

		def add_thing(group, name, thing)
			init_group(group)
			
			if !@metadata["AWS::CloudFormation::Init"]["config"][group][name]
				@metadata["AWS::CloudFormation::Init"]["config"][group][name] = []
			end

			@metadata["AWS::CloudFormation::Init"]["config"][group][name] << thing
		end


		def set_thing(group, subgroup, name, thing)
			init_group(group)
			
			if !@metadata["AWS::CloudFormation::Init"]["config"][group][subgroup]
				@metadata["AWS::CloudFormation::Init"]["config"][group][subgroup] = {}
			end

			@metadata["AWS::CloudFormation::Init"]["config"][group][subgroup][name] = thing
		end

		def set_thing2(group, name, thing)
			init_group(group)

			@metadata["AWS::CloudFormation::Init"]["config"][group][name] = thing
		end

		def yum(package)
			set_thing("packages", "yum", package, [])
		end

		def gem(package)
			set_thing("packages", "rubygems", package, [])
		end

		def rpm(package)
			set_thing("packages", "rpm", package, [])
		end

		def file(name, options={})
			info = {
				"content" => "",
				"group" => "root",
				"owner" => "root",
				"mode" => "000600",
				"context" => {},
			}

			info["content"] = options[:content] if options[:content]
			info["group"] = options[:group] if options[:group]
			info["mode"] = options[:mode] if options[:mode]
			info["owner"] = options[:owner] if options[:owner]
			info["context"] = Momo.resolve(options[:context]) if options[:context]

			set_thing2("files", name, info)
		end

		def service(service_name)
			set_thing("services", "sysvinit", service_name, {enabled: true, ensureRunning: true})
		end


		def tag(key, value, options={})
			if !@props["Tags"]
				@props["Tags"] = []
			end

			theTag = { "Key" => key, "Value" => Momo.resolve(value) }
			theTag["PropagateAtLaunch"] = options[:propagate_at_launch] if options[:propagate_at_launch]

			@props["Tags"] << theTag
		end

		def depends_on(resource)
			if resource.is_a? String
				@dependencies << args[0]
			elsif resource.is_a? Resource
				@dependencies << resource.name
			else
				raise "Invalid argument to depends_on: #{resource[0]}"
			end
		end

	end
end