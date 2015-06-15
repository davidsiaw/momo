module Momo
	class Stack

		def initialize(&block)
			raise "Stack expects a block" unless block

			@description = "No description"
			@resources = {}
			@parameters = {}
			@outputs = {}

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

		def param(options)
			@parameters[options[:name]] = options
			options
		end

		def make(type, options = {}, &block)

			name = options[:name]
			name = make_random_string if !name

			resource = Resource.new(type, name)
			resource.instance_eval(&block)

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


		def templatize_resources
			temp = {}
			@resources.each do |name, res|
				temp[name] = {"Type" => res.type, "Properties" => {}}
				res.props.each do |propname, prop|
					temp[name]["Properties"][propname] = prop
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

				temp[name] = {"Type" => typeConv[param[:type]], "NoEcho" => true}
				temp[name]["Default"] = param[:default] if param.has_key? :default
			end
			temp
		end
	end
end