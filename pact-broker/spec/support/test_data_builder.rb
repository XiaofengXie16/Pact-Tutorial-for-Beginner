require 'pact_broker/repositories'
require 'pact_broker/services'
require 'pact_broker/webhooks/repository'
require 'pact_broker/webhooks/service'
require 'pact_broker/domain/webhook_execution_result'
require 'pact_broker/pacts/repository'
require 'pact_broker/pacts/service'
require 'pact_broker/pacticipants/repository'
require 'pact_broker/pacticipants/service'
require 'pact_broker/versions/repository'
require 'pact_broker/versions/service'
require 'pact_broker/tags/repository'
require 'pact_broker/labels/repository'
require 'pact_broker/tags/service'
require 'pact_broker/domain'
require 'json'
require 'pact_broker/versions/repository'
require 'pact_broker/pacts/repository'
require 'pact_broker/pacticipants/repository'
require 'pact_broker/verifications/repository'
require 'pact_broker/verifications/service'
require 'pact_broker/tags/repository'
require 'pact_broker/webhooks/repository'
require 'pact_broker/certificates/certificate'
require 'ostruct'

class TestDataBuilder

  include PactBroker::Repositories
  include PactBroker::Services

  attr_reader :pacticipant
  attr_reader :consumer
  attr_reader :provider
  attr_reader :consumer_version
  attr_reader :pact
  attr_reader :webhook
  attr_reader :webhook_execution
  attr_reader :triggered_webhook

  def create_pricing_service
    @pricing_service_id = pacticipant_repository.create(:name => 'Pricing Service', :repository_url => 'git@git.realestate.com.au:business-systems/pricing-service').save(raise_on_save_failure: true).id
    self
  end

  def create_contract_proposal_service
    @contract_proposal_service_id = pacticipant_repository.create(:name => 'Contract Proposal Service', :repository_url => 'git@git.realestate.com.au:business-systems/contract-proposal-service').save(raise_on_save_failure: true).id
    self
  end

  def create_contract_proposal_service_version number
    @contract_proposal_service_version_id = version_repository.create(number: number, pacticipant_id: @contract_proposal_service_id).id
    self
  end

  def create_contract_email_service
    @contract_email_service_id = pacticipant_repository.create(:name => 'Contract Email Service', :repository_url => 'git@git.realestate.com.au:business-systems/contract-email-service').save(raise_on_save_failure: true).id
    self
  end

  def create_contract_email_service_version number
    @contract_email_service_version_id = version_repository.create(number: number, pacticipant_id: @contract_email_service_id).id
    self
  end

  def create_ces_cps_pact
    @pact_id = pact_repository.create(version_id: @contract_email_service_version_id, consumer_id: @contract_email_service_id, provider_id: @contract_proposal_service_id, json_content: default_json_content).id
    self
  end

  def create_condor
    @condor_id = pacticipant_repository.create(:name => 'Condor').save(raise_on_save_failure: true).id
    self
  end

  def create_condor_version number
    @condor_version_id = version_repository.create(number: number, pacticipant_id: @condor_id).id
    self
  end

  def create_pricing_service_version number
    @pricing_service_version_id = version_repository.create(number: number, pacticipant_id: @pricing_service_id).id
    self
  end

  def create_condor_pricing_service_pact
    @pact_id = pact_repository.create(version_id: @condor_version_id, consumer_id: @condor_id, provider_id: @pricing_service_id, json_content: default_json_content).id
    self
  end

  def create_pact_with_hierarchy consumer_name = "Consumer", consumer_version = "1.2.3", provider_name = "Provider", json_content = default_json_content
    create_consumer consumer_name
    create_provider provider_name
    create_consumer_version consumer_version
    create_pact json_content: json_content
    self
  end

  def create_version_with_hierarchy pacticipant_name, pacticipant_version
    pacticipant = PactBroker::Domain::Pacticipant.create(:name => pacticipant_name)
    version = PactBroker::Domain::Version.create(:number => pacticipant_version, :pacticipant => pacticipant)
    PactBroker::Domain::Version.find(id: version.id) # Get version with populated order
  end

  def create_tag_with_hierarchy pacticipant_name, pacticipant_version, tag_name
    version = create_version_with_hierarchy pacticipant_name, pacticipant_version
    PactBroker::Domain::Tag.create(name: tag_name, version: version)
  end

  def create_pacticipant pacticipant_name
    @pacticipant = PactBroker::Domain::Pacticipant.create(:name => pacticipant_name)
    self
  end

  def create_consumer consumer_name = "Consumer #{model_counter}"
    create_pacticipant consumer_name
    @consumer = @pacticipant
    self
  end

  def use_consumer consumer_name
    @consumer = PactBroker::Domain::Pacticipant.find(:name => consumer_name)
    self
  end

  def create_provider provider_name = "Provider #{model_counter}"
    create_pacticipant provider_name
    @provider = @pacticipant
    self
  end

  def use_provider provider_name
    @provider = PactBroker::Domain::Pacticipant.find(:name => provider_name)
    self
  end

  def create_version version_number = "1.0.#{model_counter}"
    @version = PactBroker::Domain::Version.create(:number => version_number, :pacticipant => @pacticipant)
    self
  end

  def create_consumer_version version_number = "1.0.#{model_counter}"
    @consumer_version = PactBroker::Domain::Version.create(:number => version_number, :pacticipant => @consumer)
    self
  end

  def create_provider_version version_number = "1.0.#{model_counter}"
    @version = PactBroker::Domain::Version.create(:number => version_number, :pacticipant => @provider)
    @provider_version = @version
    self
  end

  def use_consumer_version version_number
    @consumer_version = PactBroker::Domain::Version.where(pacticipant_id: @consumer.id, number: version_number).single_record
    self
  end

  def use_provider_version version_number
    @provider_version = PactBroker::Domain::Version.where(pacticipant_id: @provider.id, number: version_number).single_record
    self
  end

  def create_tag tag_name
    @tag = PactBroker::Domain::Tag.create(name: tag_name, version: @version)
    self
  end

  def create_consumer_version_tag tag_name
    @tag = PactBroker::Domain::Tag.create(name: tag_name, version: @consumer_version)
    self
  end

  def create_provider_version_tag tag_name
    @tag = PactBroker::Domain::Tag.create(name: tag_name, version: @provider_version)
    self
  end

  def create_label label_name
    @label = PactBroker::Domain::Label.create(name: label_name, pacticipant: @pacticipant)
    self
  end

  def create_pact params = {}
    @pact = PactBroker::Pacts::Repository.new.create({version_id: @consumer_version.id, consumer_id: @consumer.id, provider_id: @provider.id, json_content: params[:json_content] || default_json_content})
    set_created_at_if_set params[:created_at], :pact_publications, {id: @pact.id}
    set_created_at_if_set params[:created_at], :pact_versions, {sha: @pact.pact_version_sha}
    @pact = PactBroker::Pacts::PactPublication.find(id: @pact.id).to_domain
    self
  end

  def create_same_pact params = {}
    last_pact_version = PactBroker::Pacts::PactVersion.order(:id).last
    create_pact json_content: last_pact_version.content
  end

  def revise_pact json_content = nil
    json_content = json_content ? json_content : {random: rand}.to_json
    @pact = PactBroker::Pacts::Repository.new.update(@pact.id, json_content: json_content)
    self
  end

  def create_webhook params = {}
    uuid = params[:uuid] || PactBroker::Webhooks::Service.next_uuid
    event_params = params[:events] || [{ name: PactBroker::Webhooks::WebhookEvent::DEFAULT_EVENT_NAME }]
    events = event_params.collect{ |e| PactBroker::Webhooks::WebhookEvent.new(e) }
    default_params = { method: 'POST', url: 'http://example.org', headers: {'Content-Type' => 'application/json'}}
    request = PactBroker::Domain::WebhookRequest.new(default_params.merge(params))
    @webhook = PactBroker::Webhooks::Repository.new.create uuid, PactBroker::Domain::Webhook.new(request: request, events: events), @consumer, @provider
    self
  end

  def create_triggered_webhook params = {}
    trigger_uuid = params[:trigger_uuid] || webhook_service.next_uuid
    @triggered_webhook = webhook_repository.create_triggered_webhook trigger_uuid, @webhook, @pact, PactBroker::Webhooks::Service::RESOURCE_CREATION
    @triggered_webhook.update(status: params[:status]) if params[:status]
    set_created_at_if_set params[:created_at], :triggered_webhooks, {id: @triggered_webhook.id}
    self
  end

  def create_webhook_execution params = {}
    logs = params[:logs] || "logs"
    webhook_execution_result = PactBroker::Domain::WebhookExecutionResult.new(OpenStruct.new(code: "200"), logs, nil)
    @webhook_execution = PactBroker::Webhooks::Repository.new.create_execution @triggered_webhook, webhook_execution_result
    created_at = params[:created_at] || @pact.created_at + Rational(1, 86400)
    set_created_at_if_set created_at, :webhook_executions, {id: @webhook_execution.id}
    @webhook_execution = PactBroker::Webhooks::Execution.find(id: @webhook_execution.id)
    self
  end

  def create_deprecated_webhook_execution params = {}
    create_webhook_execution params
    Sequel::Model.db[:webhook_executions].where(id: webhook_execution.id).update(
      triggered_webhook_id: nil,
      consumer_id: consumer.id,
      provider_id: provider.id,
      webhook_id: PactBroker::Webhooks::Webhook.find(uuid: webhook.uuid).id,
      pact_publication_id: pact.id
    )
    self
  end

  def create_verification parameters = {}
    provider_version_number = parameters[:provider_version] || '4.5.6'
    default_parameters = {success: true, number: 1, test_results: {some: 'results'}}
    parameters = default_parameters.merge(parameters)
    parameters.delete(:provider_version)
    verification = PactBroker::Domain::Verification.new(parameters)
    @verification = PactBroker::Verifications::Repository.new.create(verification, provider_version_number, @pact)
    self
  end

  def create_certificate options = {path: 'spec/fixtures/single-certificate.pem'}
    PactBroker::Certificates::Certificate.create(uuid: SecureRandom.urlsafe_base64, content: File.read(options[:path]))
    self
  end

  def model_counter
    @@model_counter ||= 0
    @@model_counter += 1
    @@model_counter
  end

  def and_return instance_variable_name
    instance_variable_get("@#{instance_variable_name}")
  end

  private

  def set_created_at_if_set created_at, table_name, selector
    if created_at
      Sequel::Model.db[table_name].where(selector.keys.first => selector.values.first).update(created_at: created_at)
    end
  end

  def default_json_content
    {
      "consumer"     => {
         "name" => "Condor"
       },
       "provider"     => {
         "name" => "Pricing Service"
       },
       "interactions" => [],
       "random" => rand
     }.to_json
   end

end
