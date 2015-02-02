require 'aws-sdk-core'

module Momo
	class MomoAws

		def initialize(region)

			conf = Momo::MomoConfig.new
			conf.read_config

			@ec2 = Aws::EC2::Client.new(
				access_key_id: conf.aws_access_key,
		  		secret_access_key: conf.aws_secret_key,
		  		region:region)

			@cloudfront = Aws::CloudFront::Client.new(
				access_key_id: conf.aws_access_key,
		  		secret_access_key: conf.aws_secret_key,
		  		region:region)

			@s3 = Aws::S3::Client.new(
				access_key_id: conf.aws_access_key,
		  		secret_access_key: conf.aws_secret_key,
		  		region:region)

			@rds = Aws::RDS::Client.new(
				access_key_id: conf.aws_access_key,
		  		secret_access_key: conf.aws_secret_key,
		  		region:region)

			@virtualization_types = {
				"t1.micro"    => :pv ,
				"t2.micro"    => :hvm,
				"t2.small"    => :hvm,
				"t2.medium"   => :hvm,
				"m1.small"    => :pv ,
				"m1.medium"   => :pv ,
				"m1.large"    => :pv ,
				"m1.xlarge"   => :pv ,
				"m2.xlarge"   => :pv ,
				"m2.2xlarge"  => :pv ,
				"m2.4xlarge"  => :pv ,
				"m3.medium"   => :hvm,
				"m3.large"    => :hvm,
				"m3.xlarge"   => :hvm,
				"m3.2xlarge"  => :hvm,
				"c1.medium"   => :pv ,
				"c1.xlarge"   => :pv ,
				"c3.large"    => :hvm,
				"c3.xlarge"   => :hvm,
				"c3.2xlarge"  => :hvm,
				"c3.4xlarge"  => :hvm,
				"c3.8xlarge"  => :hvm,
				"g2.2xlarge"  => :hvm,
				"r3.large"    => :hvm,
				"r3.xlarge"   => :hvm,
				"r3.2xlarge"  => :hvm,
				"r3.4xlarge"  => :hvm,
				"r3.8xlarge"  => :hvm,
				"i2.xlarge"   => :hvm,
				"i2.2xlarge"  => :hvm,
				"i2.4xlarge"  => :hvm,
				"i2.8xlarge"  => :hvm,
				"hi1.4xlarge" => :hvm,
				"hs1.8xlarge" => :hvm,
				"cr1.8xlarge" => :hvm,
				"cc2.8xlarge" => :hvm,
			}

			def get_images(filter)

				resp = @ec2.describe_images(filters: [
				    {
				      name: "owner-alias",
				      values: ["amazon"],
				    },
				    {
				      name: "name",
				      values: [filter],
				    },
				  ])

				listing = []
				resp[:images].each do |x|
					listing << { 
						name: x[:image_id], 
						desc: x[:name], 
						created: x[:creation_date] }
				end
				listing.sort! { |b,a| a[:created] <=> b[:created] }

				listing[0]
			end

			@ami_type_map = {
				pv: get_images("amzn-ami-pv*"),
				hvm: get_images("amzn-ami-hvm*"),
			}

			@nat_ami_type_map = {
				pv: get_images("amzn-ami-vpc-nat-pv*"),
				hvm: get_images("amzn-ami-vpc-nat-hvm*"),
			}

			zone_list = @ec2.describe_availability_zones()[:availability_zones]

			@zones = []

			zone_list.each do |zone|
				if zone[:state] == "available"
					@zones << zone[:zone_name]
				end
			end
			
		end

		def ami_for_instance_type(type)
			@ami_type_map[@virtualization_types[type]]
		end

		def ami_for_nat_instance_type(type)
			@nat_ami_type_map[@virtualization_types[type]]
		end

		def availability_zones
			@zones
		end

		def ec2
			@ec2
		end

		def s3
			@s3
		end

		def cloudfront
			@cloudfront
		end

		def rds
			@rds
		end

	end
end