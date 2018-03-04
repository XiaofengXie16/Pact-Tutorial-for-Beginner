require 'webmachine/adapters/rack_mapped'
require 'pact_broker/api/resources'

module PactBroker

  API ||= begin
    pact_api = Webmachine::Application.new do |app|
      app.routes do
        add(['trace', :*], Webmachine::Trace::TraceResource) unless ENV['RACK_ENV'] == 'production'

        add ['pacts', 'provider', :provider_name, 'consumer', :consumer_name, 'versions'], Api::Resources::PactVersions, {resource_name: "pact_publications"}
        add ['pacts', 'provider', :provider_name, 'consumer', :consumer_name, 'versions', :consumer_version_number], Api::Resources::Pact, {resource_name: "pact_publication", deprecated: true} # Not the standard URL, but keep for backwards compatibility

        # Pacts
        add ['pacts', 'provider', :provider_name, 'consumer', :consumer_name, 'version', :consumer_version_number], Api::Resources::Pact, {resource_name: "pact_publication"}
        add ['pacts', 'provider', :provider_name, 'consumer', :consumer_name, 'version', :consumer_version_number, 'previous-distinct'], Api::Resources::PreviousDistinctPactVersion, {resource_name: "previous_distinct_pact_version"}
        add ['pacts', 'provider', :provider_name, 'consumer', :consumer_name, 'version', :consumer_version_number, 'diff', 'previous-distinct'], Api::Resources::PactContentDiff, {resource_name: "previous_distinct_pact_version_diff"}

        # Verifications
        add ['pacts', 'provider', :provider_name, 'consumer', :consumer_name, 'pact-version', :pact_version_sha, 'verification-results'], Api::Resources::Verifications, {resource_name: "verification_results"}
        add ['pacts', 'provider', :provider_name, 'consumer', :consumer_name, 'pact-version', :pact_version_sha, 'verification-results', :verification_number], Api::Resources::Verification, {resource_name: "verification_result"}
        add ['verification-results', 'consumer', :consumer_name, 'version', :consumer_version_number,'latest'], Api::Resources::LatestVerificationsForConsumerVersion, {resource_name: "verification_results_for_consumer_version"}

        # Badges
        add ['pacts', 'provider', :provider_name, 'consumer', :consumer_name, 'latest', 'badge'], Api::Resources::Badge, {resource_name: "latest_pact_badge"}
        add ['pacts', 'provider', :provider_name, 'consumer', :consumer_name, 'latest', :tag, 'badge'], Api::Resources::Badge, {resource_name: "latest_tagged_pact_badge"}
        add ['pacts', 'provider', :provider_name, 'consumer', :consumer_name, 'latest-untagged', 'badge'], Api::Resources::Badge, {resource_name: "latest_untagged_pact_badge", tag: :untagged}

        # Latest pacts
        add ['pacts', 'provider', :provider_name, 'consumer', :consumer_name, 'latest'], Api::Resources::LatestPact, {resource_name: "latest_pact_publication"}
        add ['pacts', 'provider', :provider_name, 'consumer', :consumer_name, 'latest', :tag], Api::Resources::LatestPact, {resource_name: "latest_tagged_pact_publication"}
        add ['pacts', 'provider', :provider_name, 'consumer', :consumer_name, 'latest-untagged'], Api::Resources::LatestPact, {resource_name: "latest_untagged_pact_publication", tag: :untagged}
        add ['pacts', 'provider', :provider_name, 'latest'], Api::Resources::LatestProviderPacts, {resource_name: "latest_provider_pact_publications"}
        add ['pacts', 'provider', :provider_name, 'latest', :tag], Api::Resources::LatestProviderPacts, {resource_name: "latest_tagged_provider_pact_publications"}
        add ['pacts', 'latest'], Api::Resources::LatestPacts, {resource_name: "latest_pacts"}

        # Deprecated pact
        add ['pact', 'provider', :provider_name, 'consumer', :consumer_name, 'version', :consumer_version_number], Api::Resources::Pact, {resource_name: "pact_publications", deprecated: "true"} # Deprecate, singular /pact
        add ['pact', 'provider', :provider_name, 'consumer', :consumer_name, 'latest'], Api::Resources::LatestPact, {resource_name: "latest_pact_publications", deprecated: "true"}

        # Pacticipants
        add ['pacticipants'], Api::Resources::Pacticipants, {resource_name: "pacticipants"}
        add ['pacticipants', 'label', :label_name], PactBroker::Api::Resources::PacticipantsForLabel, {resource_name: "pacticipants_for_label"}
        add ['pacticipants', :name], Api::Resources::Pacticipant, {resource_name: "pacticipant"}
        add ['pacticipants', :pacticipant_name, 'versions'], Api::Resources::Versions, {resource_name: "pacticipant_versions"}
        add ['pacticipants', :pacticipant_name, 'versions', :pacticipant_version_number], Api::Resources::Version, {resource_name: "pacticipant_version"}
        add ['pacticipants', :pacticipant_name, 'latest-version', :tag], Api::Resources::Version, {resource_name: "latest_tagged_pacticipant_version"}
        add ['pacticipants', :pacticipant_name, 'latest-version'], Api::Resources::Version, {resource_name: "latest_pacticipant_version"}
        add ['pacticipants', :pacticipant_name, 'versions', :pacticipant_version_number, 'tags', :tag_name], Api::Resources::Tag, {resource_name: "pacticipant_version_tag"}
        add ['pacticipants', :pacticipant_name, 'labels', :label_name], Api::Resources::Label, {resource_name: "pacticipant_label"}

        # Webhooks
        add ['webhooks', 'provider', :provider_name, 'consumer', :consumer_name ], Api::Resources::PactWebhooks, {resource_name: "pact_webhooks"}
        add ['webhooks', 'provider', :provider_name, 'consumer', :consumer_name, 'status' ], Api::Resources::PactWebhooksStatus, {resource_name: "pact_webhooks_status"}

        add ['webhooks', :uuid ], Api::Resources::Webhook, {resource_name: "webhook"}
        add ['webhooks', :uuid, 'trigger', :trigger_uuid, 'logs' ], Api::Resources::TriggeredWebhookLogs, {resource_name: "triggered_webhook_logs"}
        add ['webhooks', :uuid, 'execute' ], Api::Resources::WebhookExecution, {resource_name: "execute_webhook"}
        add ['webhooks'], Api::Resources::Webhooks, {resource_name: "webhooks"}

        add ['relationships'], Api::Resources::Relationships, {resource_name: "relationships"}
        add ['groups', :pacticipant_name], Api::Resources::Group, {resource_name: "group"}

        # matrix
        add ['matrix', 'provider', :provider_name, 'consumer', :consumer_name], Api::Resources::MatrixForConsumerAndProvider, {resource_name: "matrix_consumer_provider"}
        add ['matrix', 'provider', :provider_name, 'latest', :provider_tag, 'consumer', :consumer_name, 'latest', :tag, 'badge'], Api::Resources::MatrixBadge, {resource_name: "matrix_tag_badge"}
        add ['matrix'], Api::Resources::Matrix, {resource_name: "matrix"}

        add [], Api::Resources::Index, {resource_name: "index"}
      end
    end

    pact_api.configure do |config|
      config.adapter = :RackMapped
    end

    pact_api.adapter
  end
end
