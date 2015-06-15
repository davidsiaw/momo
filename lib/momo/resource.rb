module Momo
	class Resource
		def initialize(type, name)
			@type = type
			@name = name
			@props = {}
		end

		def method_missing(name, *args, &block)
			if args[0].has_key? :name
				@props[name] = { "Ref" => args[0][:name] }
			elsif args[0].is_a? String
				@props[name] = args[0]
			else
				raise "Invalid var: #{args[0]}"
			end
		end

		def name
			@name
		end

		def type
			@type
		end

		def props
			@props
		end

	end
end