
module Momo

	def Momo.resolve(something, options={})
		
		if something.is_a? String or 
			something.is_a? TrueClass or 
			something.is_a? FalseClass or
			something.is_a? Numeric
			return something
		elsif something.is_a? Array
			result = []
			something.each do |elem|
				result << Momo.resolve(elem)
			end
			return result 
		elsif something.is_a? Hash
			result = {}
			something.each do |key, value|
				result[key] = Momo.resolve(value)
			end
			return result
		elsif something.is_a? Resource
			return { "Ref" => something.name }
		elsif something.is_a? Reference
			return something.representation
		elsif something.is_a? FuncCall
			return something.representation
		elsif something.is_a? Parameter
			return { "Ref" => something.name }
		else
			raise "Invalid var: '#{something}' in #{options[:resource]}"
		end
	end
	
	class MomoScope

		def call(name, *args)
			FuncCall.new(name, *args)
		end

		def ref(resource)
			Reference.new(resource)
		end

		def lookup(map_name, key, item)
			call("Fn::FindInMap", map_name, key, item)
		end
	end
end