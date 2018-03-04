require 'spec_helper'
require 'pact_broker/api/decorators/pacticipant_decorator'
require 'pact_broker/domain/pacticipant'

module PactBroker

  module Api

    module Decorators

      describe PacticipantDecorator do

        let(:test_data_builder) { TestDataBuilder.new }
        let(:pacticipant) do
          test_data_builder
            .create_pacticipant('Name')
            .create_label('foo')
            .and_return(:pacticipant)
        end

        let(:created_at) { Time.new(2014, 3, 4) }
        let(:updated_at) { Time.new(2014, 3, 5) }

        before do
          pacticipant.created_at = created_at
          pacticipant.updated_at = updated_at
        end

        subject { JSON.parse PacticipantDecorator.new(pacticipant).to_json(user_options: {base_url: 'http://example.org'}), symbolize_names: true }

        it "includes timestamps" do
          expect(subject[:createdAt]).to eq created_at.xmlschema
          expect(subject[:updatedAt]).to eq updated_at.xmlschema
        end

        it "includes embedded labels" do
          expect(subject[:_embedded][:labels].first).to include name: 'foo'
          expect(subject[:_embedded][:labels].first[:_links][:self][:href]).to match %r{http://example.org/.*foo}
        end

        context "when there is a latest_version" do
          before { test_data_builder.create_version("1.2.107") }
          it "includes an embedded latestVersion" do
            expect(subject[:_embedded][:latestVersion]).to include number: "1.2.107"
          end

          it "includes an embedded latest-version for backwards compatibility" do
            expect(subject[:_embedded][:'latest-version']).to include number: "1.2.107"
          end

          it "includes a deprecation warning" do
            expect(subject[:_embedded][:'latest-version']).to include title: "DEPRECATED - please use latestVersion"
          end
        end

        context "when there is no latest_version" do
          it "doesn't blow up" do
            expect(subject[:_embedded]).to_not have_key(:latestVersion)
            expect(subject[:_embedded]).to_not have_key(:'latest-version')
          end
        end
      end
    end
  end
end
