Sequel.migration do
  up do
    # These views find the latest triggered webhook for each webhook/consumer/provider
    # by finding the latest execution date for each webhook
    # then taking the row with the max ID in case there there are two
    # triggered webhooks for the same UUID and same creation date
    # Not sure if this is strictly necessary to do the extra step, but better to be
    # safe than sorry.
    # I probably could just take the max ID for each webhook/consumer/provider, but
    # something in my head says that
    # relying on the primary key for order is not a good idea, even though
    # according to the SQL it should be fine.

    create_or_replace_view(:latest_triggered_webhook_creation_dates,
      "select webhook_uuid, consumer_id, provider_id, max(created_at) as latest_triggered_webhook_created_at
      from triggered_webhooks
      group by webhook_uuid, consumer_id, provider_id"
    )

    # Ignore ltwcd.latest_triggered_webhook_created_at, it's there because postgres doesn't allow you to modify
    # the names and types of columns in a view
    create_or_replace_view(:latest_triggered_webhook_ids,
      "select tw.webhook_uuid, tw.consumer_id, tw.provider_id, ltwcd.latest_triggered_webhook_created_at, max(tw.id) as latest_triggered_webhook_id
      from latest_triggered_webhook_creation_dates ltwcd
      inner join triggered_webhooks tw
      on tw.consumer_id = ltwcd.consumer_id
      and tw.provider_id = ltwcd.provider_id
      and tw.webhook_uuid = ltwcd.webhook_uuid
      and tw.created_at = ltwcd.latest_triggered_webhook_created_at
      group by tw.webhook_uuid, tw.consumer_id, tw.provider_id, ltwcd.latest_triggered_webhook_created_at"
    )

    create_or_replace_view(:latest_triggered_webhooks,
      "select tw.*
      from triggered_webhooks tw
      inner join latest_triggered_webhook_ids ltwi
      on tw.consumer_id = ltwi.consumer_id
      and tw.provider_id = ltwi.provider_id
      and tw.webhook_uuid = ltwi.webhook_uuid
      and tw.id = ltwi.latest_triggered_webhook_id"
    )
  end

  down do
    create_or_replace_view(:latest_triggered_webhook_ids,
      "select webhook_uuid, consumer_id, provider_id, max(created_at) as latest_triggered_webhook_created_at
      from triggered_webhooks
      group by webhook_uuid, consumer_id, provider_id"
    )

    create_or_replace_view(:latest_triggered_webhooks,
      "select tw.*
      from triggered_webhooks tw
      inner join latest_triggered_webhook_ids ltwi
      on tw.consumer_id = ltwi.consumer_id
      and tw.provider_id = ltwi.provider_id
      and tw.webhook_uuid = ltwi.webhook_uuid
      and tw.created_at = ltwi.latest_triggered_webhook_created_at"
    )

    drop_view(:latest_triggered_webhook_creation_dates)
  end
end