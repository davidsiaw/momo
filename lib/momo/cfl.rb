require "momo/stack.rb"

module Momo
	class CFL

		def initialize(&block)
			@stack = Stack.new(&block)
		end

		def templatize()

			template = {"AWSTemplateFormatVersion" => "2010-09-09"}
			template["Description"] = @stack.description

			template["Mappings"] = @stack.templatize_mappings
			template["Resources"] = @stack.templatize_resources
			template["Conditions"] = @stack.templatize_conditions
			template["Parameters"] = @stack.templatize_params if @stack.parameters.length > 0
			template["Outputs"] = @stack.templatize_outputs if @stack.outputs.length > 0

			template.to_json
		end

		
	end
end