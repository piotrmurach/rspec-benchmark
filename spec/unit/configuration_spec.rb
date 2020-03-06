# frozen_string_literal: true

RSpec.describe RSpec::Benchmark do
  after(:example) do
    RSpec::Benchmark.reset_configuration
  end

  it "defaults :run_in_subprocess option to false" do
    config = RSpec::Benchmark.configuration

    expect(config.run_in_subprocess).to eq(false)
  end

  it "defaults :disable_gc option to false" do
    config = RSpec::Benchmark.configuration

    expect(config.disable_gc).to eq(false)
  end

  it "defaults :samples option to 1" do
    config = RSpec::Benchmark.configuration

    expect(config.samples).to eq(1)
  end

  it "defaults :format option to :human" do
    config = RSpec::Benchmark.configuration

    expect(config.format).to eq(:human)
  end

  it "sets :run_in_subprocess option to true" do
    RSpec::Benchmark.configure do |config|
      config.run_in_subprocess = true
    end

    config = RSpec::Benchmark.configuration

    expect(config.run_in_subprocess).to eq(true)
  end

  it "sets :disable_gc option to true" do
    RSpec::Benchmark.configure do |config|
      config.disable_gc = true
    end

    config = RSpec::Benchmark.configuration

    expect(config.disable_gc).to eq(true)
  end

  it "sets :samples option to 10" do
    RSpec::Benchmark.configure do |config|
      config.samples = 10
    end

    config = RSpec::Benchmark.configuration

    expect(config.samples).to eq(10)
  end

  it "uses the :run_in_subprocess option in timing matcher" do
    RSpec::Benchmark.configure do |config|
      config.run_in_subprocess = true
      config.samples = 10
    end

    bench = [0.005, 0.00001]
    allow(::Benchmark::Perf).to receive(:cpu).and_return(bench)

    expect { 'x' * 1024 }.to perform_under(0.1)

    expect(::Benchmark::Perf).to have_received(:cpu).with(
      subprocess: true, warmup: 1, repeat: 10)
  end

  it "uses the :samples option in complexity matcher" do
    RSpec::Benchmark.configure do |config|
      config.samples = 10
    end

    bench = [:constant, {constant: {residual: 0.9}}]
    allow(::Benchmark::Trend).to receive(:infer_trend).and_return(bench)

    expect { 'x' * 1024 }.to perform_constant

    expect(::Benchmark::Trend).to have_received(:infer_trend).with(
      [8, 64, 512, 4096, 8192], repeat: 10)
  end
end
