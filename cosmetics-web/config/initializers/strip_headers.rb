class StripInsecureHeaders
  def initialize(app)
    @app = app
  end

  def call(env)
    env.delete("HTTP_X_FORWARDED_HOST")
    @app.call(env)
  end
end

Rails.application.config.middleware.insert_before(0, StripInsecureHeaders) if Rails.env.production?
