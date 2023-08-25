require 'prometheus/middleware/exporter'
require 'prometheus/client'

class Openapm::Middleware

  def initialize(app)
    @app = app
    @metric_path = "/metrics"
    @registry =  Prometheus::Client.registry
    @histogram = Prometheus::Client::Histogram.new(:http_requests_duration_milliseconds,
                                                   docstring: 'Duration of HTTP requests in milliseconds',
                                                   labels: [:path, :method, :status],
                                                   buckets: [0.25, 1.5, 31]
                                                  )
    @registry.register(@histogram)

  end

  def call(env)
    return Prometheus::Middleware::Exporter.new(@app, { registry: @registry}).call(env) if env['PATH_INFO'] == @metric_path


    start = Time.now
    result = @app.call(env)
    result
  ensure
    if env['PATH_INFO'] != @metric_path
      status = (result && result[0]) || -1
      @histogram.observe(Time.now - start, labels: { path: env['PATH_INFO'], method: env['REQUEST_METHOD'], status: status })
    end
  end
end
