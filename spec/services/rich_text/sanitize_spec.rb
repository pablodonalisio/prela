require "rails_helper"

RSpec.describe RichText::Sanitize do
  it "keeps text formatting" do
    html = '<p style="text-align: center">Hola <strong>equipo</strong></p>'

    expect(described_class.call(html)).to include("<strong>equipo</strong>")
    expect(described_class.call(html)).to match(/text-align:\s*center/i)
  end

  it "keeps a safe text color and link" do
    html = '<p><span style="color: #112233">Nota</span> <a href="https://prela.test/informe">ver</a></p>'
    result = described_class.call(html)

    expect(result).to match(/color:\s*#112233/i)
    expect(result).to include('href="https://prela.test/informe"')
    expect(result).to include('rel="noopener noreferrer"')
  end

  it "strips images, videos and embedded urls" do
    html = <<~HTML
      <p>Visible</p>
      <img src="data:image/png;base64,aaaa" alt="foto">
      <video src="clip.mp4"></video>
      <iframe src="https://example.test"></iframe>
      <p style="color: red; background-image: url(https://evil.test/a.png)">resto</p>
    HTML
    result = described_class.call(html)

    expect(result).to include("Visible")
    expect(result).to include("resto")
    expect(result).not_to include("<img")
    expect(result).not_to include("data:image")
    expect(result).not_to include("<video")
    expect(result).not_to include("<iframe")
    expect(result).not_to include("url(")
    expect(result).not_to include("background-image")
  end

  it "drops javascript links" do
    result = described_class.call('<a href="javascript:alert(1)">texto</a>')

    expect(result).to include("texto")
    expect(result).not_to include("javascript")
    expect(result).not_to include("href")
  end

  it "returns nothing for an image-only body" do
    expect(described_class.call('<p><img src="foto.png"></p>')).to eq("")
  end

  it "leaves plain text unchanged" do
    expect(described_class.call("Texto base")).to eq("Texto base")
  end
end
