RSpec.describe Warren do
  it "config saves" do

    Warren.configure do |config|
      config.node_name = "bunny"
    end

    expect(Warren.config.node_name).to eq("bunny")
  end
end
