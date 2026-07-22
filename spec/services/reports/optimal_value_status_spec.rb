require "rails_helper"

RSpec.describe Reports::OptimalValueStatus do
  describe ".valid_format?" do
    it "accepts an exact number" do
      expect(described_class.valid_format?("220")).to be true
      expect(described_class.valid_format?("220.5")).to be true
    end

    it "accepts inclusive ranges with hyphen or dashes" do
      expect(described_class.valid_format?("220-240")).to be true
      expect(described_class.valid_format?("220 - 240")).to be true
      expect(described_class.valid_format?("220–240")).to be true
    end

    it "rejects invalid formats" do
      expect(described_class.valid_format?("220 ± 5%")).to be false
      expect(described_class.valid_format?("abc")).to be false
      expect(described_class.valid_format?("240-220")).to be false
    end
  end

  describe ".call" do
    it "returns :ok for an exact match" do
      expect(
        described_class.call(type: "float", measured_value: "220", optimal_value: "220")
      ).to eq(:ok)
    end

    it "returns :not_ok when the exact value does not match" do
      expect(
        described_class.call(type: "float", measured_value: "221", optimal_value: "220")
      ).to eq(:not_ok)
    end

    it "returns :ok when the measure is inside the range" do
      expect(
        described_class.call(type: "float", measured_value: "230", optimal_value: "220-240")
      ).to eq(:ok)
    end

    it "returns :ok on inclusive range bounds" do
      expect(
        described_class.call(type: "integer", measured_value: "220", optimal_value: "220-240")
      ).to eq(:ok)
      expect(
        described_class.call(type: "integer", measured_value: "240", optimal_value: "220-240")
      ).to eq(:ok)
    end

    it "returns :not_ok when the measure is outside the range" do
      expect(
        described_class.call(type: "float", measured_value: "210", optimal_value: "220-240")
      ).to eq(:not_ok)
    end

    it "returns nil when the measure is blank" do
      expect(
        described_class.call(type: "float", measured_value: "", optimal_value: "220")
      ).to be_nil
    end

    it "returns :ok when the string measure matches the optimal text" do
      expect(
        described_class.call(type: "string", measured_value: "Correcto", optimal_value: "Correcto")
      ).to eq(:ok)
    end

    it "returns :not_ok when the string measure does not match the optimal text" do
      expect(
        described_class.call(type: "string", measured_value: "Incorrecto", optimal_value: "Correcto")
      ).to eq(:not_ok)
    end

    it "ignores surrounding whitespace for string comparison" do
      expect(
        described_class.call(type: "string", measured_value: " Correcto ", optimal_value: "Correcto")
      ).to eq(:ok)
    end

    it "returns nil when the optimal value is blank" do
      expect(
        described_class.call(type: "float", measured_value: "220", optimal_value: nil)
      ).to be_nil
    end
  end
end
