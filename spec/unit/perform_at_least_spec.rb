# frozen_string_literal: true

RSpec.describe '#perform_at_least' do
  it "allows to configure matcher timings" do
    bench = [10_000, 100]
    allow(::Benchmark::Perf::Iteration).to receive(:run).and_return(bench)

    expect {
      'x' * 1024 * 10
    }.to perform_at_least(10_000).within(0.3).warmup(0.2)

    expect(::Benchmark::Perf::Iteration).to have_received(:run).
      with(time: 0.3, warmup: 0.2)
  end

  context "expect { ... }.to perform_at_least(...).ips" do
    it "passes if the block perfoms more than 10K ips" do
      expect {
        'x' * 1024 * 10
      }.to perform_at_least(10_000).ips
    end

    it "fails if the block performs less than 10K ips" do
      expect {
        expect {
          'x' * 1024 * 1024
        }.to perform_at_least(10_000).ips
      }.to raise_error(/expected block to perform at least 10000 i\/s, but performed only \d+ \(± \d+%\) i\/s/)
    end
  end

  context "expect { ... }.not_to perform_at_least(...).ips" do
    it "passes if the block does not perform more than 10K ips" do
      expect {
        'x' * 1024 * 1024 * 10
      }.not_to perform_at_least(10_000).ips
    end

    it "fails if the block performs more than 10K ips" do
      expect {
        expect { 'x' * 1024 }.not_to perform_at_least(10_000).ips
      }.to raise_error(/expected block not to perform at least 10000 i\/s, but performed \d+ \(± \d+%\) i\/s/)
    end
  end
end
