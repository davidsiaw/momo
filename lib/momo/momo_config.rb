require 'aws-sdk-core'
require 'yaml'

module Momo
	class MomoConfig

		def initialize (different_conf_file = nil)
			@config_file = File.join(Dir.home, ".momo", "config")

			if different_conf_file and different_conf_file.is_a? String
				@config_file = different_conf_file
			end

			dirname = File.dirname(@config_file)
			unless File.directory?(dirname)
			  FileUtils.mkdir_p(dirname)
			end

			if File.exists? @config_file
				@curr_config = YAML::load_file(@config_file)
			else
				@curr_config = {}
				write_config
			end

			read_config
		end

		def test_config
			begin
				# test the creds
				ec2 = Aws::EC2::Client.new(
					access_key_id: self.aws_access_key,
			  		secret_access_key: self.aws_secret_key,
					region:'ap-northeast-1'
					)

				ec2.create_vpc(
					dry_run: true,
					cidr_block: "10.1.1.0/8",
					instance_tenancy: "default"
					)

			rescue Aws::EC2::Errors::DryRunOperation
				return true

			rescue
			end

			return false

		end

		def read_config
			@curr_config = YAML.load_file(@config_file)
		end

		def write_config
			File.open(@config_file, 'w') {|f| f.write(@curr_config.to_yaml) }
		end

		def aws_access_key= (access_key)
			if !@curr_config.has_key? :aws_credentials
				@curr_config[:aws_credentials] = {}
			end

			@curr_config[:aws_credentials][:access_key] = access_key
		end

		def aws_secret_key= (secret_key)
			if !@curr_config.has_key? :aws_credentials
				@curr_config[:aws_credentials] = {}
			end

			@curr_config[:aws_credentials][:secret_key] = secret_key
		end

		def aws_access_key
			if @curr_config.has_key? :aws_credentials
				if @curr_config[:aws_credentials].has_key? :access_key
					return @curr_config[:aws_credentials][:access_key]
				end
			end

			return ""
		end

		def aws_secret_key
			if @curr_config.has_key? :aws_credentials
				if @curr_config[:aws_credentials].has_key? :secret_key
					return @curr_config[:aws_credentials][:secret_key]
				end
			end

			return ""
		end
	end
end
