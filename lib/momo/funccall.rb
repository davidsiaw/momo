
module Momo
	class FuncCall
		def initialize(name, stack, *args)
			@name = name
			@args = []
			@stack = stack
			if !stack.is_a? Stack
				raise "#{stack.inspect} is not a stack"
			end
			args.each do |arg|
				@args << Momo.resolve(arg, stack: stack)
			end
			if @args.length == 1
				@args = @args[0]
			end
		end

		def representation
			{@name => @args}
		end
	end
end
