require 'pact_broker/domain/tag'
require 'pact_broker/repositories/helpers'


module PactBroker
  module Tags
    class Repository

      include PactBroker::Repositories::Helpers

      def create args
        Domain::Tag.new(name: args.fetch(:name), version: args.fetch(:version)).save
      end

      def find args
        PactBroker::Domain::Tag
          .select_all_qualified
          .join(:versions, { id: :version_id })
          .join(:pacticipants, {Sequel.qualify("pacticipants", "id") => Sequel.qualify("versions", "pacticipant_id")})
          .where(name_like(Sequel.qualify("tags", "name"), args.fetch(:tag_name)))
          .where(name_like(Sequel.qualify("versions", "number"), args.fetch(:pacticipant_version_number)))
          .where(name_like(Sequel.qualify("pacticipants", "name"), args.fetch(:pacticipant_name)))
          .single_record
      end

      def delete_by_version_id version_id
        Sequel::Model.db[:tags].where(version_id: version_id).delete
      end

      def find_all_tag_names_for_pacticipant pacticipant_name
        PactBroker::Domain::Tag
        .select(Sequel[:tags][:name])
        .join(:versions, { Sequel[:versions][:id] => Sequel[:tags][:version_id] })
        .join(:pacticipants, { Sequel[:pacticipants][:id] => Sequel[:versions][:pacticipant_id] })
        .where(Sequel[:pacticipants][:name] => pacticipant_name)
        .distinct
        .collect{ |tag| tag[:name] }.sort
      end
    end
  end
end
