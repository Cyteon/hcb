# frozen_string_literal: true

module PendingEventMappingEngine
  module Map
    module Single
      class OutgoingDisbursement
        def initialize(canonical_pending_transaction:)
          @canonical_pending_transaction = canonical_pending_transaction
        end

        def run
          return @canonical_pending_transaction.canonical_pending_event_mapping if @canonical_pending_transaction.mapped?

          attrs = {
            event_id: @canonical_pending_transaction.raw_pending_outgoing_disbursement_transaction.likely_event_id,
            subledger_id: disbursement.source_subledger_id,
            canonical_pending_transaction_id: @canonical_pending_transaction.id
          }
          CanonicalPendingEventMapping.create!(attrs)
        end

        private

        def disbursement
          @canonical_pending_transaction.raw_pending_outgoing_disbursement_transaction.disbursement
        end

      end
    end
  end
end
