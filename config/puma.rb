# frozen_string_literal: true

ssl_key  = ENV.fetch('TCAPI_SSL_KEY', '')
ssl_cert = ENV.fetch('TCAPI_SSL_CERT', '')

unless ssl_key.empty? && ssl_cert.empty?
  ssl_bind(
    '0.0.0.0',
    '9292',
    key:        ssl_key,
    cert:       ssl_cert,
    no_tlsv1:   true,
    # This is defined by puma so I cannot change it.
    # rubocop:disable Naming/VariableNumber
    no_tlsv1_1: true
    # rubocop:enable Naming/VariableNumber
  )
end
