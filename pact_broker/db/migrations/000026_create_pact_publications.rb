Sequel.migration do
  up do
    create_table(:pact_publications, charset: 'utf8') do
      primary_key :id
      foreign_key :consumer_version_id, :versions, null: false
      foreign_key :provider_id, :pacticipants, null: false
      Integer :revision_number, null: false
      foreign_key :pact_version_id, :pact_versions, null: false
      DateTime :created_at, null: false
      index [:consumer_version_id, :provider_id, :revision_number], unique: true, name: 'cv_prov_revision_unq'
      index [:consumer_version_id, :provider_id, :id], name: 'cv_prov_id_ndx'
    end
  end
end
