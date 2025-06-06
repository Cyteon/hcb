# frozen_string_literal: true

require "rails_helper"

describe PendingTransactionEngine::CanonicalPendingTransactionService::ImportSingle::OutgoingDisbursement do

  context "when passing a raw pending outgoing_disbursement transaction that is not yet processed" do
    it "processes into a CanonicalPendingTransaction" do
      expect(RawPendingOutgoingDisbursementTransaction.count).to eq(0)

      raw_pending_outgoing_disbursement_transaction = create(:raw_pending_outgoing_disbursement_transaction, date_posted: Date.current)

      expect do
        described_class.new(raw_pending_outgoing_disbursement_transaction:).run
      end.to change { CanonicalPendingTransaction.count }.by(1)
    end
  end

  context "when passing a raw pending outgoing_disbursement transaction that is already processed" do
    let(:raw_pending_outgoing_disbursement_transaction) { create(:raw_pending_outgoing_disbursement_transaction) }

    before do
      _processed_outgoing_disbursement_canonical_pending_transaction = create(:canonical_pending_transaction,
                                                                              raw_pending_outgoing_disbursement_transaction:)
    end

    it "ignores it when processing" do
      expect do
        described_class.new(raw_pending_outgoing_disbursement_transaction:).run
      end.to change { CanonicalPendingTransaction.count }.by(0)
    end
  end


  context "in review" do
    let(:raw_pending_outgoing_disbursement_transaction) {
      create(:raw_pending_outgoing_disbursement_transaction,
             date_posted: Date.current,
             disbursement:)
    }

    before do
      raw_pending_outgoing_disbursement_transaction
    end

    context "when the disbursement is in review" do
      let(:disbursement) { create(:disbursement, aasm_state: "reviewing") }

      it "sets fronted to false" do
        expect do
          described_class.new(raw_pending_outgoing_disbursement_transaction:).run
        end.to change { CanonicalPendingTransaction.count }.by(1)

        canonical_pending_transaction = CanonicalPendingTransaction.last
        expect(canonical_pending_transaction.fronted).to eq(false)
      end
    end

    context "when the disbursement is not in review" do
      let(:disbursement) { create(:disbursement, aasm_state: "pending") }

      it "sets fronted to true" do
        expect do
          described_class.new(raw_pending_outgoing_disbursement_transaction:).run
        end.to change { CanonicalPendingTransaction.count }.by(1)

        canonical_pending_transaction = CanonicalPendingTransaction.last
        expect(canonical_pending_transaction.fronted).to eq(true)
      end
    end
  end

  context "rest of the attributes" do
    let(:raw_pending_outgoing_disbursement_transaction) {
      create(:raw_pending_outgoing_disbursement_transaction,
             date_posted: Date.current,
             disbursement:)
    }

    before do
      raw_pending_outgoing_disbursement_transaction
    end

    context "when processed" do
      let(:disbursement) { create(:disbursement) }

      it "copies the attributes over to the pending canonical transaction" do
        expect do
          described_class.new(raw_pending_outgoing_disbursement_transaction:).run
        end.to change { CanonicalPendingTransaction.count }.by(1)

        canonical_pending_transaction = CanonicalPendingTransaction.last
        expect(canonical_pending_transaction.date).to eq(raw_pending_outgoing_disbursement_transaction.date_posted)
        expect(canonical_pending_transaction.memo).to eq(raw_pending_outgoing_disbursement_transaction.memo)
      end
    end
  end
end
