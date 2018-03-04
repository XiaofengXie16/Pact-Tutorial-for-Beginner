require 'pact_broker/domain/version'

module PactBroker

  module Domain

    describe Version do
      describe "#latest_pact_publication" do
        let!(:pact) do
          TestDataBuilder.new
            .create_consumer
            .create_provider
            .create_consumer_version
            .create_pact
            .revise_pact
            .and_return(:pact)
        end
        let(:version) { Version.order(:id).last }

        it "returns the latest pact revision for the consumer version" do
          expect(version.latest_pact_publication.id).to eq pact.id
        end
      end

      describe "uq_ver_ppt_ord" do
        let(:consumer) do
          TestDataBuilder.new
            .create_consumer
            .and_return(:consumer)
        end

        it "does not allow two versions with the same pacticipant and order" do
          Sequel::Model.db[:versions].insert(number: '1', order: 0, pacticipant_id: consumer.id, created_at: DateTime.new(2017), updated_at: DateTime.new(2017))
          expect { Sequel::Model.db[:versions].insert(number: '2', order: 0, pacticipant_id: consumer.id, created_at: DateTime.new(2017), updated_at: DateTime.new(2017)) }
            .to raise_error(Sequel::UniqueConstraintViolation)
        end
      end
    end
  end
end
