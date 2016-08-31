require 'momo/momoscope'

module Momo

	class Stack < MomoScope

		attr_accessor :resources, :parameters, :conditions, :outputs

		def initialize(&block)
			raise "Stack expects a block" unless block

			@description = "No description"
			@resources = {}
			@parameters = {}
			@outputs = {}
			@mappings = {}
			@conditions = {}
			@stack = self

			@names = {}

			@ids = {}
			instance_eval(&block)
		end

		def inject(module_object=nil, &block)
			extend module_object if module_object
			instance_eval &block if block
		end

		def description(*args)
			if (args.length == 1)
				@description = args[0]
			else
				@description
			end
		end
 
		def make_default_resource_name (type)
			match = /\:?\:?([a-zA-Z0-9]+)$/.match(type)
			if match == nil
				raise "Invalid resource name: #{type}"
			end
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
			@parameters[name] = Parameter.new(name, self, options)
		end

		def condition(cond_expr, &block)
			Momo.resolve(cond_expr, stack: self, resource: cond_expr.signature)
			previous_condition = @current_condition

			if previous_condition
				cond_expr = BooleanValue.new("Fn::And", self, {"Condition" => previous_condition}, {"Condition" => cond_expr.signature})
				Momo.resolve(cond_expr, stack: self, resource: cond_expr.signature)
			end
			@current_condition = cond_expr.signature
			instance_eval(&block)
			@current_condition = previous_condition
		end

		def make(type, options = {}, &block)

			name = options[:name]
			name = make_default_resource_name(type) if !name

			resource = Resource.new(type, name, self)
			resource.condition = @current_condition
			resource.instance_eval(&block) if block
			resource.complete!

			raise "Resource #{name} already exists" if @resources.has_key? resource.name
			@resources[resource.name] = resource
			resource
		end

		def output(name, res)
			@outputs[name] = Momo.resolve(res, stack: self)
		end

		def mapping(name, &block)
			@mappings[name] = Mapping.new(&block).major_keys
		end

		def templatize_mappings
			@mappings
		end

		def templatize_conditions
			@conditions
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

				if res.condition
					temp[name]["Condition"] = res.condition
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