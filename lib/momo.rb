require "momo/version"
require 'aws-sdk-core'
require 'yaml'
require 'JSON'

require 'momo/cfl'
require 'momo/reference'
require 'momo/funccall'
require 'momo/memberreference'
require 'momo/momoscope'
require 'momo/parameter'
require 'momo/resource'
require 'momo/mapping'
require 'momo/stack'


module Momo

	def self.cfl(&block)
		Momo::CFL.new(&block)
	end

end