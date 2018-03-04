require 'pact_broker/api/decorators/embedded_label_decorator'

module PactBroker
  module Api
    module Decorators

      describe LabelDecorator do

        let(:label) do
          TestDataBuilder.new
            .create_consumer("Consumer")
            .create_label("ios")
            .and_return(:label)
        end

        let(:options) { { user_options: { base_url: 'http://example.org' } } }

        subject { JSON.parse EmbeddedLabelDecorator.new(label).to_json(options), symbolize_names: true }

        it "includes the label name" do
          expect(subject[:name]).to eq "ios"
        end

        it "includes a link to itself" do
          expect(subject[:_links][:self][:href]).to eq "http://example.org/pacticipants/Consumer/labels/ios"
        end

        it "includes the label name" do
          expect(subject[:_links][:self][:name]).to eq "ios"
        end
      end
    end
  end
end
