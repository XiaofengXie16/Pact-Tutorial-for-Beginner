require 'spec/support/test_data_builder'

describe "Get versions" do

  let(:path) { "/pacticipants/Consumer/versions" }
  let(:last_response_body) { JSON.parse(subject.body, symbolize_names: true) }

  subject { get path; last_response }

  context "when the pacticipant exists" do

    before do
      TestDataBuilder.new
        .create_consumer("Consumer")
        .create_consumer_version("1.0.0")
        .create_consumer_version("1.0.1")
    end

    it "returns a 200 response" do
      expect(subject.status).to be 200
    end

    it "returns a list of links to the versions" do
      expect(last_response_body[:_links][:"versions"].size).to eq 2
    end

  end

  context "when the pacticipant does not exist" do

    it "returns a 404 response" do
      expect(subject).to be_a_404_response
    end

  end
end
