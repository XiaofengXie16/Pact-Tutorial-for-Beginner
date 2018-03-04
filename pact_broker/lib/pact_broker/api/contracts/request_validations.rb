require 'reform'
require 'reform/contract'
require 'net/http'

module PactBroker
  module Api
    module Contracts

      module RequestValidations
        def method_is_valid
          http_method && !valid_method?
        end

        def valid_method?
          Net::HTTP.const_defined?(http_method.capitalize)
        end

        def url_is_valid
          url && !url_valid?
        end

        def url_valid?
          uri && uri.scheme && uri.host
        end

        def uri
          URI(url)
        rescue URI::InvalidURIError
          nil
        end
      end
    end
  end
end
