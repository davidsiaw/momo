module Momo

	class MemberReference < FuncCall
		def initialize(resource_name, member_name, stack)
			@resource = resource_name
			@member = member_name
			super("Fn::GetAtt", stack, "#{resource_name}", "#{member_name}")
		end

		def member
			@member
		end

		def method_missing(name, *args, &block)
			MemberReference.new(@resource, "#{@member}.#{name}", @stack)
		end
	end

end