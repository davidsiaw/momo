require 'momo'

describe Momo::MomoConfig do
	it "Config file does not exist" do
		conf = Momo::MomoConfig.new ("nyan.config")
		expect(conf.test_config).to eq(false)
	end

	it "Config file does not exist. Key should be empty" do
		conf = Momo::MomoConfig.new ("nyan.config")
		expect(conf.aws_access_key).to eq("")
	end

	it "Config file does not exist. Secret should be empty" do
		conf = Momo::MomoConfig.new ("nyan.config")
		expect(conf.aws_secret_key).to eq("")
	end

	it "Writing to the access key should work" do
		conf = Momo::MomoConfig.new ("nyan.config")
		conf.aws_access_key = "abcd"
		expect(conf.aws_access_key).to eq("abcd")
	end

	it "Writing to the secret key should work" do
		conf = Momo::MomoConfig.new ("nyan.config")
		conf.aws_secret_key = "abcd"
		expect(conf.aws_secret_key).to eq("abcd")
	end
end
