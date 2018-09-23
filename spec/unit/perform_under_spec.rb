# encoding: utf-8

RSpec.describe 'RSpec::Benchmark::TimingMatcher', '#perform_under' do
  it "propagates error inside expectation" do
    expect {
      expect { raise 'boom' }.to perform_under(0.01).sec
    }.to raise_error(StandardError, /boom/)
  end

  it "allows to configure warmup cycles" do
    bench = [0.005, 0.00001]
    allow(::Benchmark::Perf::ExecutionTime).to receive(:run).and_return(bench)
    expect { 'x' * 1024 * 10 }.to perform_under(0.006, warmup: 1.5).sec.sample(3)
    expect(::Benchmark::Perf::ExecutionTime).to have_received(:run).with(repeat: 3, warmup: 1.5)
  end

  context "expect { ... }.to perfom_under(...).sample" do
    it "passes if the block performs under threshold" do
      expect {
        'x' * 1024 * 10
      }.to perform_under(0.006).sec.sample(10)
    end

    it "fails if the block performs above threshold" do
      expect {
        expect {
          'x' * 1024 * 1024 * 100
        }.to perform_under(0.0001).sample(5)
      }.to raise_error(/expected block to perform under 100 μs, but performed above \d+(\.\d+)? ([μmn]s|sec) \(± \d+(\.\d+)? ([μmn]s|sec)\)/)
    end
  end

  context "expect { ... }.not_to perform_under(...).sample" do
    it "passes if the block does not perform under threshold" do
      expect {
        'x' * 1024 * 1024 * 10
      }.to_not perform_under(0.001).sample(2)
    end

    it "fails if the block perfoms under threshold" do
      expect {
        expect {
          'x' * 1024 * 1024 * 10
        }.to_not perform_under(1).sample(2)
      }.to raise_error(/expected block to not perform under 1 sec, but performed \d+(\.\d+)? ([μmn]s|sec) \(± \d+(\.\d+)? ([μmn]s|sec)\) under/)
    end
  end

  context 'threshold conversions' do
    it "converts 1ms to sec" do
      matcher = perform_under(1).ms
      expect(matcher.threshold).to eq(0.001)
    end

    it "converts 1000us to sec" do
      matcher = perform_under(1000).us
      expect(matcher.threshold).to eq(0.001)
    end

    it "converts ns to sec" do
      matcher = perform_under(100_000).ns
      expect(matcher.threshold).to eq(0.0001)
    end
  end
end
