module Momo

	class MemberReference < FuncCall
		def initialize(resource_name, member_name)
			@resource = resource_name
			@member = member_name
			super("Fn::GetAtt", "#{resource_name}", "#{member_name}")
		end

		def member
			@member
		end

		def method_missing(name, *args, &block)
			MemberReference.new(@resource, "#{@member}.#{name}")
		end
	end

end