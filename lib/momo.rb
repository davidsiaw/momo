require "momo/version"
require 'aws-sdk-core'
require 'yaml'
require 'JSON'

require 'momo/cfl'
require 'momo/reference'
require 'momo/funccall'
require 'momo/momoscope'
require 'momo/parameter'
require 'momo/resource'
require 'momo/mapping'
require 'momo/stack'


def cfl(&block)
	Momo::CFL.new(&block)
end

def checkcfl(profile, region, template)

	cf = Aws::CloudFormation::Client.new(
		region: region, 
		profile: profile)

	cf.validate_template(template_body: template)
end

def runcfl(profile, region, name, template)

	cf = Aws::CloudFormation::Client.new(
		region: region, 
		profile: profile)

	cf.create_stack(
		stack_name: name,
		template_body: template)
end


