require "rails_helper"

RSpec.describe QrToken, type: :model do
  describe "on location equipment" do
    it "does not create a token when the equipment is created" do
      location_equipment = create(:location_equipment)

      expect(location_equipment.qr_token).to be_nil
      expect(location_equipment.qr_tokens).to be_empty
    end

    it "creates a kept token on demand and reuses it" do
      location_equipment = create(:location_equipment)

      token = location_equipment.ensure_qr_token!
      again = location_equipment.ensure_qr_token!

      expect(token).to be_persisted
      expect(token.token).to be_present
      expect(token).to be_kept
      expect(again).to eq(token)
      expect(location_equipment.qr_tokens.kept).to contain_exactly(token)
    end

    it "discards the kept token and inserts a new one" do
      location_equipment = create(:location_equipment)
      previous = location_equipment.ensure_qr_token!

      replacement = location_equipment.regenerate_qr_token!

      expect(previous.reload).to be_discarded
      expect(QrToken.exists?(previous.id)).to be(true)
      expect(replacement).to be_kept
      expect(replacement.id).not_to eq(previous.id)
      expect(replacement.token).not_to eq(previous.token)
      expect(location_equipment.reload.qr_token).to eq(replacement)
    end

    it "returns the location equipment show path" do
      location_equipment = create(:location_equipment)

      expect(location_equipment.qr_destination_path).to eq(
        Rails.application.routes.url_helpers.location_equipment_path(location_equipment)
      )
    end
  end
end
