shared_examples "admin level access policy" do |record = nil|
  let(:record) { record ? create(record) : :headless }

  it "grants access if user is admin" do
    expect(subject).to permit(admin, record)
  end

  it "denies access if user is not admin" do
    expect(subject).not_to permit(client, record)
  end
end

shared_examples "client level access policy" do |record = nil|
  let(:record) { record ? create(record) : :headless }

  it "grants access if user is admin" do
    expect(subject).to permit(admin, record)
  end

  it "grants access if user is client" do
    expect(subject).to permit(client, record)
  end
end
