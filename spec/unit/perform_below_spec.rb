# encoding: utf-8

RSpec.describe 'RSpec::Benchmark::TimingMatcher', '#perform_below' do

  context "expect { ... }.to perfom_below(...).and_sample" do
    it "passes if the block performs below threshold" do
      expect {
        'x' * 1024 * 10
      }.to perform_below(0.001).and_sample(10)
    end

    it "fails if the block performs above threshold" do
      expect {
        expect {
          'x' * 1024 * 1024 * 10
        }.to perform_below(0.0001).and_sample(10)
      }.to raise_error(/expected block to perform below 0\.0001 threshold, but performed above \d+\.\d+ \(± \d+\.\d+\) seconds/)
    end
  end

  context "expect { ... }.not_to perform_below(...).and_sample" do
    it "passes if the block does not perform below threshold" do
      expect {
        'x' * 1024 * 1024 * 10
      }.to_not perform_below(0.001).and_sample(2)
    end

    it "fails if the block perfoms below threshold" do
      expect {
        expect {
          'x' * 1024 * 1024 * 10
        }.to_not perform_below(0.1).and_sample(2)
      }.to raise_error(/expected block to not perform below 0\.1 threshold, but performed \d+\.\d+ \(± \d+\.\d+\) seconds below/)
    end
  end
end
