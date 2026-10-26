require "rails_helper"

RSpec.describe "Contract dates", type: :system do
  let(:admin) { create(:admin) }
  let(:client) { create(:client) }
  let(:contract) { create(:contract, client:, starts_on: Date.new(2026, 1, 1), ends_on: Date.new(2026, 6, 1)) }

  before { login_as(admin, scope: :user) }

  it "blocks an end date before the start date" do
    visit edit_client_contract_path(client, contract)

    expect(page).to have_css("#contract_starts_on_date[data-datepicker-ready]")
    end_input = find("#contract_ends_on_date")
    expect(end_input[:min]).to eq("2026-01-01")

    start_input = find("#contract_starts_on_date")
    page.execute_script("arguments[0].datepicker.setDate(new Date(2026, 7, 1))", start_input)

    expect(end_input[:min]).to eq("2026-08-01")
    expect(end_input.value).to eq("")
    expect(find("input[name='contract[ends_on]']", visible: :all).value).to eq("")
  end
end
