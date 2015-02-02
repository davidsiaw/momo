require 'momo'

describe Momo::MomoCloud do
	it "Use direct reference" do
		structure = momo_create do
			vpc = vpc "VPC", cidr_block: "10.1.0.0/16"
			gateway "Internet Gateway", vpc: vpc
		end

  		expect(structure[:resources]["Internet Gateway"][:vpc]).to eq(structure[:resources]["VPC"])
	end

	it "Use indirect reference" do
		structure = momo_create do
			vpc "VPC", cidr_block: "10.1.0.0/16"
			gateway "Internet Gateway", vpc: "VPC"

		end

  		expect(structure[:resources]["Internet Gateway"][:vpc]).to eq(structure[:resources]["VPC"])
	end
end
