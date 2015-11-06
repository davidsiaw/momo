
module Momo
	class Reference
		def initialize(res)
			@res = res
		end

		def representation
			{"Ref" => @res}
		end

		def method_missing(name, *args, &block)
			puts "Ref missing #{name}"
		end
	end
end
