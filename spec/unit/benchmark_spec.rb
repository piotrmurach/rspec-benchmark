# encoding: utf-8

RSpec.describe Benchmark::Perf do
  it "calculates average without measurements" do
    expect(Benchmark::Perf.average([])).to eq(0)
  end

  it "provides linear range" do
    bench = Benchmark::Perf::ExecutionTime.new
    expect(bench.linear_range(0, 3)).to eq([0,1,2,3])
  end

  it "provides default benchmark range" do
    bench = Benchmark::Perf::ExecutionTime.new
    expect(bench.bench_range.size).to eq(30)
  end

  it "provides measurements for 30 samples by default" do
    bench = Benchmark::Perf::ExecutionTime.new
    sample = bench.run { 'x' * 1024 }
    expect(sample).to all(be < 0.01)
  end

  it "executes code to warmup ruby vm" do
    bench = Benchmark::Perf::ExecutionTime.new
    sample = bench.run_warmup { 'x' * 1_000_000 }
    expect(sample).to be < 0.01
  end

  it "measures work performance for 10 samples" do
    bench = Benchmark::Perf::ExecutionTime.new
    sample = bench.run(10) { 'x' * 1_000_000 }
    expect(sample.size).to eq(2)
    expect(sample).to all(be < 0.01)
  end

  it "defines cycles per 100 microseconds" do
    bench = Benchmark::Perf::Iteration.new
    sample = bench.run_warmup { 'x' * 1_000_000 }
    expect(sample).to be > 25
  end

  it "measures 10K iterations per second" do
    bench = Benchmark::Perf::Iteration.new
    sample = bench.run { 'x' * 1_000_000 }
    expect(sample.size).to eq(4)
    expect(sample[0]).to be > 300
    expect(sample[1]).to be > 5
    expect(sample[2]).to be > 300
  end
end
