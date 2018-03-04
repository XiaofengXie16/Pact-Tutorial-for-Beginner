require 'pact_broker/api/resources/badge'

module PactBroker
  module Api
    module Resources
      class MatrixBadge < Badge

        private

        def latest_verification
          @latest_verification ||= verification_service.find_latest_verification_for_tags(
            identifier_from_path[:consumer_name],
            identifier_from_path[:provider_name],
            identifier_from_path[:tag],
            identifier_from_path[:provider_tag]
          )
        end
      end
    end
  end
end
