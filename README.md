# Momo Cloudformation template builder

Let's face it. Amazon Cloudformation Templates are shit. Amazon Web Services does not know how to make proper representations. Using JSON to call functions and create if statements is like cutting pies with a holepuncher and a waterhose. Its messy, it wastes time and its about as hygenic as drinking mud. But its the most efficient way to craft a piece of cloud infrastructure before you hand in your resignation and party the rest of your life away.

Momo solves this problem by allowing you to make concise templates using Ruby and giving you all the for loops and if conditions in their best form, and not use the stupid condition shit that makes DeMorgan roll in his grave.

Momo is called momo because we here at MObingi made it, and momo is the word for peach in Japanese, which is quite tasty.

## Installation

Add this line to your application's Gemfile:

    gem 'momo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install momo

## Usage

Here's a basic way of using momo

```ruby
require 'momo'

template = cfl do
	# Make a VPC
	vpc = make "AWS::EC2::VPC" do
		CidrBlock "10.0.0.0/16"
		EnableDnsSupport true
		EnableDnsHostnames true
	end

	# Write the VPC id as output
	output vpc
end

# Output the template as JSON.
puts template.templatize()
```

## Contributing

1. Fork it ( https://github.com/davidsiaw/momo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
