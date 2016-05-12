require 'momo/momoscope'

module Momo

	class MappingRow < MomoScope
		attr_accessor :values

		def initialize(&block)
			@values = {}
			instance_eval(&block)
		end

		def item(name, value)
			@values[name] = value
		end
	end

	class Mapping < MomoScope
		attr_accessor :major_keys

		def initialize(&block)
			@major_keys = {}
			instance_eval(&block)
		end

		def key(name, &block)
			@major_keys[name] = MappingRow.new(&block).values
		end
	end

	class Stack < MomoScope

		attr_accessor :resources, :parameters, :outputs

		def initialize(&block)
			raise "Stack expects a block" unless block

			@description = "No description"
			@resources = {}
			@parameters = {}
			@outputs = {}
			@mappings = {}

			@names = {}

			@ids = {}
			instance_eval(&block)
		end


		def description(*args)
			if (args.length == 1)
				@description = args[0]
			else
				@description
			end
		end

		def make_default_resource_name (type)
			match = /\:?\:?([a-zA-Z]+)$/.match(type)
			name = match.captures[0]

			if !@names[name]
				@names[name] = 1
			else
				@names[name] += 1
			end

			"#{name}#{@names[name]}"
		end

		def make_random_string
			id = ""
			loop do 
				o = [('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten
				id = (1...20).map { o[rand(o.length)] }.join
				break if !@ids.has_key?(id)
			end 

			@ids[id] = true
			id
		end

		def param(name, options={})
			@parameters[name] = Parameter.new(name, options)
		end

		def make(type, options = {}, &block)

			name = options[:name]
			name = make_default_resource_name(type) if !name

			resource = Resource.new(type, name)
			resource.instance_eval(&block) if block
			resource.complete!

			raise "Resource #{name} already exists" if @resources.has_key? resource.name
			@resources[resource.name] = resource
			resource
		end

		def output(name, res)
			if res.is_a? Resource
				@outputs[name] = { "Ref" => res.name }
			elsif res.is_a? String
				@props[name] = res
			else
				raise "Invalid var: #{res}"
			end
		end

		def mapping(name, &block)
			@mappings[name] = Mapping.new(&block).major_keys
		end

		def templatize_mappings
			@mappings
		end

		def templatize_resources
			temp = {}
			@resources.each do |name, res|
				temp[name] = {"Type" => res.type, "Properties" => {}}
				res.props.each do |propname, prop|
					temp[name]["Properties"][propname] = prop
				end

				if res.metadata
					temp[name]["Metadata"] = res.metadata
				end

				if res.dependencies.length != 0
					temp[name]["DependsOn"] = res.dependencies
				end
				
				if res.deletion_policy
					temp[name]["DeletionPolicy"] = res.deletion_policy
				end
			end
			temp
		end

		def templatize_outputs
			temp = {}
			@outputs.each do |name, res|
				temp[name] = {"Value" => res}
			end
			temp
		end

		def templatize_params
			temp = {}
			@parameters.each do |name, param|
				typeConv = {
					string: "String",
					number: "Number",
					list: "List"
				}

				temp[name] = {"Type" => typeConv[param.options[:type]]}
				temp[name]["NoEcho"] = true unless param.options[:no_echo] == false
				temp[name]["Description"] = param.options[:description] if param.options.has_key? :description
				temp[name]["Default"] = param.options[:default] if param.options.has_key? :default
				temp[name]["AllowedValues"] = param.options[:allowed] if param.options.has_key? :allowed
			end
			temp
		end
	end
end