require "momo/funccall"

module Momo

	def Momo.resolve(something, options={})

		if something.is_a? String or 
			something.is_a? TrueClass or 
			something.is_a? FalseClass or
			something.is_a? Numeric
			return something
		elsif something.is_a? Array
			result = []
			something.each do |elem|
				result << Momo.resolve(elem, options)
			end
			return result 
		elsif something.is_a? Hash
			result = {}
			something.each do |key, value|
				result[key] = Momo.resolve(value, options)
			end
			return result
		elsif something.is_a? Resource
			return { "Ref" => something.name }
		elsif something.is_a? Reference
			return something.representation
		elsif something.is_a? BooleanValue
			options[:stack].conditions[something.signature] = something.representation
			return { "Condition" => something.signature }
		elsif something.is_a? FuncCall
			return something.representation
		elsif something.is_a? Parameter
			return { "Ref" => something.name }
		else
			raise "Invalid var: '#{something}' in #{options[:resource]}"
		end
	end
	
	class MomoScope
		def call(name, *args)
			FuncCall.new(name, @stack, *args)
		end

		def ref(resource)
			Reference.new(resource)
		end

		def lookup(map_name, key, item)
			call("Fn::FindInMap", map_name, key, item)
		end
	end

	class BooleanValue < FuncCall

		def initialize(operator, stack, *args)
			super(operator, stack, args)
		end

		def not()
			BooleanValue.new("Fn::Not", @stack, self)
		end

		def signature_of(something)
			if something.is_a? String or 
				something.is_a? TrueClass or 
				something.is_a? FalseClass or
				something.is_a? Numeric
				return something
			elsif something.is_a? Hash
				return something["Ref"] || something["Condition"]
			elsif something.is_a? BooleanValue
				return something.signature
			elsif something.is_a? Resource
				return something.name
			end
		end

		def signature()
			match = /Fn::(?<name>[a-z]+)/i.match(@name)
			"#{signature_of(@args[0])}#{match[:name]}#{signature_of(@args[1])}"
		end

	end

	module MomoCondition

		def equals(another)
			BooleanValue.new("Fn::Equals", @stack, self, another)
		end

		def and(another)
			BooleanValue.new("Fn::And", @stack, self, another)
		end

		def or(another)
			BooleanValue.new("Fn::Or", @stack, self, another)
		end

	end

end
