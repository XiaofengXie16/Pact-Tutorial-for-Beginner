Sequel.migration do
  up do
    # provider_version is DEPRECATED, use provider_version_number
    create_or_replace_view(:all_verifications,
      from(:verifications).select(
        Sequel[:verifications][:id],
        Sequel[:verifications][:number],
        :success,
        :provider_version_id,
        Sequel[:v][:number].as(:provider_version_number),
        Sequel[:v][:order].as(:provider_version_order),
        :build_url,
        :pact_version_id,
        :execution_date,
        Sequel[:verifications][:created_at]
        ).join(:versions, {id: :provider_version_id}, {:table_alias => :v})
    )
  end

  down do
    drop_view(:all_verifications)
  end
end
