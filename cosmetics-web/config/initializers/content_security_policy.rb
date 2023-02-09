# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
#     policy.style_src   :self, :https
#     # Specify URI for violation reports
#     # policy.report_uri "/csp-violation-report-endpoint"
#   end
#
#   # Generate session nonces for permitted importmap and inline scripts
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src)
#
#   # Report violations without enforcing the policy.
#   # config.content_security_policy_report_only = true
# end

defaults = %i[self https]
ga_urls = %w[https://www.googletagmanager.com https://www.google-analytics.com]

Rails.application.config.content_security_policy do |policy|
  policy.base_uri(:self)
  policy.default_src(*defaults)
  policy.font_src(*defaults, :data)
  policy.img_src(*defaults, :data, *ga_urls)
  policy.object_src(:none)
  # Modern browsers supporting CSP3 will apply "nonce + strict-dynamic" more restrictive policies. They will ignore "unsafe-inline".
  # "unsafe-inline" adds backwards compatibility with older browsers not supporting nonce from CSP3
  policy.script_src(*defaults, :strict_dynamic, :unsafe_inline, *ga_urls)
  policy.style_src(*defaults, :unsafe_inline)

  # Specify URI for violation reports
  policy.report_uri ENV.fetch("SENTRY_SECURITY_HEADER_ENDPOINT", "")
end

# Enable Report Only if you want the policy violations to be reported but not blocked, effectively allowing
# the violating script execution.
Rails.application.config.content_security_policy_report_only = false
Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]
