require 'pact_broker/constants'
require 'sequel'

module Rack
  module PactBroker
    class DatabaseTransaction

      REQUEST_METHOD = "REQUEST_METHOD".freeze
      TRANS_METHODS = %w{POST PUT PATCH DELETE}.freeze

      def initialize app, database_connection
        @app = app
        @database_connection = database_connection
      end

      def call env
        if use_transaction? env
          call_with_transaction env
        else
          call_without_transaction env
        end
      end

      def use_transaction? env
        TRANS_METHODS.include? env[REQUEST_METHOD]
      end

      def call_without_transaction env
        @app.call(env)
      end

      def call_with_transaction env
        response = nil
        @database_connection.transaction do
          response = @app.call(env)
          if response.first == 500
            raise Sequel::Rollback unless do_not_rollback?(response)
          end
        end
        response
      end

      def do_not_rollback? response
        response[1].delete(::PactBroker::DO_NOT_ROLLBACK)
      end
    end
  end
end
