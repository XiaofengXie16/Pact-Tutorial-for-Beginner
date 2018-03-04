require 'reform'
require 'reform/form'

module PactBroker
  module Api
    module Contracts
      class WebhookContract < Reform::Form

        validation do
          configure do
            config.messages_file = File.expand_path("../../../locale/en.yml", __FILE__)
          end

          required(:request).filled
          optional(:events).maybe(min_size?: 1)
        end

        property :request do
          property :url
          property :http_method

          validation do
            configure do
              config.messages_file = File.expand_path("../../../locale/en.yml", __FILE__)

              def valid_method?(value)
                Net::HTTP.const_defined?(value.capitalize)
              end

              def valid_url?(value)
                uri = URI(value)
                uri.scheme && uri.host
              rescue URI::InvalidURIError
                false
              end
            end

            required(:http_method).filled(:valid_method?)
            required(:url).filled(:valid_url?)
          end
        end

        collection :events do
          property :name

          validation do
            required(:name).filled
          end
        end
      end
    end
  end
end
