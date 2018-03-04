require_relative 'migration_helper'

Sequel.migration do
  change do
    create_table(:pact_versions, charset: 'utf8') do
      primary_key :id
      foreign_key :consumer_id, :pacticipants
      foreign_key :provider_id, :pacticipants
      String :sha, null: false
      String :content, type: PactBroker::MigrationHelper.large_text_type
      index [:consumer_id, :provider_id, :sha], unique: true, name: 'unq_pvc_con_prov_sha'
      DateTime :created_at, null: false
    end
  end
end
