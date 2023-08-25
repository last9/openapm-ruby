# Openapm

APM for Rack based Ruby applications using Prometheus and Grafana.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'openapm'
```

And then execute:

$ bundle

Or install it yourself as:

$ gem install openapm

## Usage

### Rack application

```ruby
# config.ru
require 'rack'
require 'openapm/middleware'

use Rack::Deflater
use Openapm::Middleware
```

This will start emitting the RED metrics for HTTP requests on `/metrics` path.

You can scrape it using a Prometheus and visualize it in Grafana.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/prathamesh-sonpatki/openapm. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [Apache 2 License](https://www.apache.org/licenses/LICENSE-2.0).

## Code of Conduct

Everyone interacting in the Openapm project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/last9/openapm/blob/master/CODE_OF_CONDUCT.md).
