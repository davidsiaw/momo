
module Momo
	class Reference
		def initialize(res)
			@res = res
		end

		def representation
			{"Ref" => @res}
		end
	end
end