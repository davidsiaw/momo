
module Momo
	class Parameter
		attr_accessor :name, :options

		include MomoCondition

		def initialize(name, stack, options={})
			@name = name
			@stack = stack
			@options = options
		end
	end
end