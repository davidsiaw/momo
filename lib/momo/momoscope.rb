require "momo/funccall"

module Momo

	class BlockHash
		attr_accessor :props
		def initialize(options, &block)
			@options = options
			@props = {}
			instance_eval(&block)
		end

		def method_missing(name, *args, &block)
			if /^[[:upper:]]/.match(name) == nil
				raise "Invalid property name: #{name}"
			end
			@props[name] = Momo.resolve(args[0], @options, &block)
		end
	end

	def Momo.resolve(something, options={}, &block)

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
			return { "Condition" => something.signature }
		elsif something.is_a? FuncCall
			return something.representation
		elsif something.is_a? Parameter
			return { "Ref" => something.name }
		elsif something == nil && block
			return result = BlockHash.new(options, &block).props
		else
			raise "Invalid var: #{something.inspect} in #{options[:resource]}"
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

	class BooleanValue < FuncCall

		include MomoCondition

		def initialize(operator, stack, *args)
			super(operator, stack, args)
			stack.conditions[self.signature] = self.representation
		end

		def not()
			BooleanValue.new("Fn::Not", @stack, self)
		end

		def either(val_true, val_false)
			FuncCall.new("Fn::If", @stack, self.signature, val_true, val_false)
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

end
