require 'pact_broker/api/resources/base_resource'
require 'pact_broker/configuration'
require 'pact_broker/domain/verification'
require 'pact_broker/api/contracts/verification_contract'
require 'pact_broker/api/decorators/verification_decorator'

module PactBroker
  module Api
    module Resources

      class Verification < BaseResource

        def content_types_provided
          [["application/json", :to_json]]
        end

        def allowed_methods
          ["GET"]
        end

        def resource_exists?
          !!verification
        end

        def to_json
          decorator_for(verification).to_json(user_options: {base_url: base_url})
        end

        private

        def verification
          @verification ||= verification_service.find(identifier_from_path)
        end

        def decorator_for model
          PactBroker::Api::Decorators::VerificationDecorator.new(model)
        end
      end
    end
  end
end
