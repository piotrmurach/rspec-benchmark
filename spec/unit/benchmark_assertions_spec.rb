# encoding: utf-8

RSpec.describe Benchmark::Perf, '#assert_perform' do
  it "passes asertion by performing under threshold" do
    bench = Benchmark::Perf
    assertion = bench.assert_perform_under(0.01, samples: 2) { 'x' * 1_024 }
    expect(assertion).to eq(true)
  end

  it "passes asertion by performing 10K ips" do
    bench = Benchmark::Perf
    assertion = bench.assert_perform_ips(10_000) { 'x' * 1_024 }
    expect(assertion).to eq(true)
  end
end
