require "momo/stack.rb"

module Momo
	class CFL
		def initialize(&block)
			@stack = Stack.new(&block)
		end

		def templatize()

			template = {"AWSTemplateFormatVersion" => "2010-09-09"}
			template["Description"] = @stack.description

			template["Resources"] = @stack.templatize_resources
			template["Parameters"] = @stack.templatize_params
			template["Outputs"] = @stack.templatize_outputs

			template.to_json
		end

	end
end