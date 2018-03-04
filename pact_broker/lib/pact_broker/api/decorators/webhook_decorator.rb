require_relative 'base_decorator'
require 'pact_broker/api/decorators/webhook_request_decorator'
require 'pact_broker/api/decorators/timestamps'
require 'pact_broker/domain/webhook_request'
require 'pact_broker/webhooks/webhook_event'
require 'pact_broker/api/decorators/basic_pacticipant_decorator'
require_relative 'pact_pacticipant_decorator'
require_relative 'pacticipant_decorator'

module PactBroker
  module Api
    module Decorators
      class WebhookDecorator < BaseDecorator

        class WebhookEventDecorator < BaseDecorator
          property :name
        end

        property :request, :class => PactBroker::Domain::WebhookRequest, extend: WebhookRequestDecorator
        collection :events, :class => PactBroker::Webhooks::WebhookEvent, extend: WebhookEventDecorator

        include Timestamps

        link :self do | options |
          {
            title: represented.description,
            href: webhook_url(represented.uuid, options[:base_url])
          }

        end

        link :'pb:execute' do | options |
          {
            title: "Test the execution of the webhook by sending a POST request to this URL",
            href: webhook_execution_url(represented, options[:base_url])
          }
        end


        link :'pb:consumer' do | options |
          {
            title: "Consumer",
            name: represented.consumer.name,
            href: pacticipant_url(options.fetch(:base_url), represented.consumer)
          }
        end

        link :'pb:provider' do | options |
          {
            title: "Provider",
            name: represented.provider.name,
            href: pacticipant_url(options.fetch(:base_url), represented.provider)
          }
        end

        link :'pb:pact-webhooks' do | options |
          {
            title: "All webhooks for consumer #{represented.consumer.name} and provider #{represented.provider.name}",
            href: webhooks_for_pact_url(represented.consumer, represented.provider, options[:base_url])
          }
        end

        link :'pb:webhooks' do | options |
          {
            title: "All webhooks",
            href: webhooks_url(options[:base_url])
          }
        end

        def from_json represented
          super.tap do | webhook |
            if webhook.events == nil
              webhook.events = [PactBroker::Webhooks::WebhookEvent.new(name: PactBroker::Webhooks::WebhookEvent::DEFAULT_EVENT_NAME)]
            end
          end
        end
      end
    end
  end
end
