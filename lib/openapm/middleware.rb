require 'prometheus/middleware/exporter'
require 'prometheus/client'

class Openapm::Middleware

  def initialize(app)
    @app = app
    @metric_path = "/metrics"
    @registry =  Prometheus::Client.registry
    @histogram = Prometheus::Client::Histogram.new(:http_requests_duration_milliseconds,
                                                   docstring: 'Duration of HTTP requests in milliseconds',
                                                   labels: [:path, :method, :status, :environment],
                                                   buckets: [0.25, 1.5, 31]
                                                  )
    @registry.register(@histogram)

  end

  def call(env)
    return Prometheus::Middleware::Exporter.new(@app, { registry: @registry}).call(env) if env['PATH_INFO'] == @metric_path

    # https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    result = @app.call(env)
    result
  ensure
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    if env['PATH_INFO'] != @metric_path
      # Elapsed Time in milliseconds
      elapsed_time = (ending - starting) * 1000

      status = (result && result[0]) || -1
      @histogram.observe(elapsed_time, labels: { path: env['PATH_INFO'], method: env['REQUEST_METHOD'], status: status, environment: env['RACK_ENV'] })
    end
  end
end
