require 'spec_helper'
require 'spec/support/test_data_builder'
require 'pact_broker/pacts/merger'
require 'json'

module PactBroker
  module Pacts
    describe Merger do
      let(:example_pact) { load_json_fixture('consumer-provider.json') }
      let(:example_interaction) do
        {
          "description" => "some description",
          "provider_state" => nil,
          "request" => {
            "method" => "get",
            "path" => "/cash_money",
            "headers" => {
              "Content-Type" => "application/json"
            }
          },
          "response" => {
            "status" => 200,
            "body" => "$$$$$$$$",
            "headers" => {
              "Content-Type" => "application/json"
            }
          }
        }
      end

      describe "#merge" do

        before :each do
          @pact_to_merge = load_json_fixture('consumer-provider.json')
        end

        it "merges two pacts" do
          @pact_to_merge["interactions"] << example_interaction
          result = merge_pacts(example_pact, @pact_to_merge)
          expect(result["interactions"]).to match_array(example_pact["interactions"].push(example_interaction))
        end

        it "is idempotent" do
          @pact_to_merge["interactions"] << example_interaction
          first_result = merge_pacts(example_pact, @pact_to_merge)
          second_result = merge_pacts(first_result, @pact_to_merge)
          expect(first_result).to contain_hash second_result
        end

        it "overwrites identical interactions" do
          @pact_to_merge["interactions"][0]["response"]["body"] = "changed!"
          result = merge_pacts(example_pact, @pact_to_merge)

          expect(result["interactions"].length).to eq example_pact["interactions"].length
          expect(result["interactions"].first["response"]["body"]).to eq "changed!"
        end

        it "appends interactions with a different provider state" do
          @pact_to_merge["interactions"][0]["provider_state"] = "upside down"

          result = merge_pacts(example_pact, @pact_to_merge)
          expect(result["interactions"].length).to eq example_pact["interactions"].length + 1
        end

        it "appends interactions with a different description" do
          @pact_to_merge["interactions"][0]["description"] = "getting $$$"

          result = merge_pacts(example_pact, @pact_to_merge)
          expect(result["interactions"].length).to eq example_pact["interactions"].length + 1
        end

        # helper that lets these specs deal with hashes instead of JSON strings
        def merge_pacts(a, b, return_hash = true)
          result = PactBroker::Pacts::Merger.merge_pacts(a.to_json, b.to_json)

          return_hash ? JSON.parse(result) : result
        end
      end

      describe "#conflict?" do
        before :each do
          @pact_to_compare = load_json_fixture('consumer-provider.json')
        end

        it "returns false if interactions have different descriptions" do
          @pact_to_compare["interactions"][0]["description"] = "something else"

          expect(compare_pacts(example_pact, @pact_to_compare)).to eq false
        end

        it "returns false if interactions have different provider states" do
          @pact_to_compare["interactions"][0]["provider_state"] = "some other thing"
          expect(compare_pacts(example_pact, @pact_to_compare)).to eq false
        end

        context "when interactions have the same desc/state" do
          it "returns false if request parameters are the same" do
            expect(compare_pacts(example_pact, @pact_to_compare)).to eq false
          end

          it "returns true if requests have a different query" do
            @pact_to_compare["interactions"][0]["request"]["query"] = "foo=bar&baz=qux"
            expect(compare_pacts(example_pact, @pact_to_compare)).to eq true
          end

          it "returns true if requests have a different body" do
            @pact_to_compare["interactions"][0]["request"]["body"] = { "something" => { "nested" => "deeply" } }
            expect(compare_pacts(example_pact, @pact_to_compare)).to eq true
          end

          it "returns true if request method is different" do
            @pact_to_compare["interactions"][0]["request"]["method"] = "post"
            expect(compare_pacts(example_pact, @pact_to_compare)).to eq true
          end

          it "returns true if request path is different" do
            @pact_to_compare["interactions"][0]["request"]["path"] = "/new_path"
            expect(compare_pacts(example_pact, @pact_to_compare)).to eq true
          end

          it "returns true if request headers are different" do
            @pact_to_compare["interactions"][0]["request"]["headers"]["Content-Type"] = "text/html"
            expect(compare_pacts(example_pact, @pact_to_compare)).to eq true
          end

          it "returns true if request has additional headers" do
            @pact_to_compare["interactions"][0]["request"]["headers"]["Accept"] = "text/html"
            expect(compare_pacts(example_pact, @pact_to_compare)).to eq true
          end

          it "returns true if request has missing headers" do
            @pact_to_compare["interactions"][0]["request"]["headers"].delete("Content-Type")
            expect(compare_pacts(example_pact, @pact_to_compare)).to eq true
          end
        end

        def compare_pacts(a, b)
          PactBroker::Pacts::Merger.conflict?(a.to_json, b.to_json)
        end
      end
    end
  end
end
