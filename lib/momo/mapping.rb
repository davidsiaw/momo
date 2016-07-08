require 'momo/momoscope'

module Momo
	class MappingRow < MomoScope
		attr_accessor :values

		def initialize(&block)
			@values = {}
			instance_eval(&block)
		end

		def item(name, value)
			@values[name] = value
		end
	end

	class Mapping < MomoScope
		attr_accessor :major_keys

		def initialize(&block)
			@major_keys = {}
			instance_eval(&block)
		end

		def key(name, &block)
			@major_keys[name] = MappingRow.new(&block).values
		end
	end
end