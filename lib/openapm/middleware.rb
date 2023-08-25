require 'prometheus/middleware/exporter'
require 'prometheus/client'

class Openapm::Middleware
  def initialize(app)
    @app = app
    @metric_path = "/metrics"
    @registry =  Prometheus::Client.registry
    @histogram = Prometheus::Client::Histogram.new(:http_requests_duration_milliseconds,
                                                   docstring: 'Duration of HTTP requests in milliseconds',
                                                   labels: [:program, :path, :method, :status, :environment],
                                                   buckets: [0.25, 1.5, 31],
                                                   preset_labels: Openapm.default_labels
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
      @histogram.observe(elapsed_time, labels: { path: generate_path(env), method: env['REQUEST_METHOD'], status: status, environment: ENV["RAILS_ENV"] || ENV["RACK_ENV"] })
    end
  end

  protected

  def generate_path(env)
    full_path = [env['SCRIPT_NAME'], env['PATH_INFO']].join

    sanitize_id(full_path)
  end

  def sanitize_id(path)
    path
      .gsub(%r{/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}(?=/|$)}, '/:uuid\\1')
      .gsub(%r{/\d+(?=/|$)}, '/:id\\1')
  end
end
