
module Momo
	class FuncCall
		def initialize(name, *args)
			@name = name
			@args = []
			args.each do |arg|
				@args << Momo.resolve(arg)
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