require 'rack'
require 'openapm/middleware'

use Rack::Deflater
use Openapm::Middleware

srand

app = lambda do |_|
  case rand
  when 0..0.8
    [200, { 'content-type' => 'text/html' }, ['OK']]
  when 0.8..0.95
    [404, { 'content-type' => 'text/html' }, ['Not Found']]
  else
    raise NoMethodError, 'It is a bug!'
  end
end

run app
