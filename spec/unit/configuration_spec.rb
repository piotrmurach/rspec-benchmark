# frozen_string_literal: true

RSpec.describe RSpec::Benchmark do
  after(:example) do
    RSpec::Benchmark.reset_configuration
  end

  it "defaults all config options to false" do
    config = RSpec::Benchmark.configuration

    expect(config.run_in_subprocess).to eq(false)
    expect(config.disable_gc).to eq(false)
  end

  it "sets :run_in_subprocess option to true" do
    RSpec::Benchmark.configure do |config|
      config.run_in_subprocess = true
    end

    config = RSpec::Benchmark.configuration

    expect(config.run_in_subprocess).to eq(true)
    expect(config.disable_gc).to eq(false)
  end

  it "sets :disable_gc option to true" do
    RSpec::Benchmark.configure do |config|
      config.disable_gc = true
    end

    config = RSpec::Benchmark.configuration

    expect(config.run_in_subprocess).to eq(false)
    expect(config.disable_gc).to eq(true)
  end
end
