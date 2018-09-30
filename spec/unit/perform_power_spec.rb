# frozen_string_literal: true

RSpec.describe 'RSpec::Benchmark::ComplexityMatcher', '#perform_power' do
  def prefix_avg(numbers)
    result = []
    numbers.each_with_index do |i, num|
      sum = 0.0
      numbers[0..i].each do |a|
        sum += a
      end
      result[i] = sum / i
    end
    result
  end

  it "propagates error inside expectation" do
    expect {
      expect { raise 'boom' }.to perform_power
    }.to raise_error(StandardError, /boom/)
  end

  context "expect { ... }.to perfom_power" do
    it "passes if the block performs power" do
      range = bench_range(10, 8 << 5)
      numbers = range.map { |n| Array.new(n) { rand(n) } }

      expect { |n, i|
        prefix_avg(numbers[i])
      }.to perform_power.in_range(range[0], range[-1]).sample(100).times
    end

    it "fails if the block doesn't perform power" do
      expect {
        expect { |n| n }.to perform_power.in_range(1, 10_000).sample(100)
      }.to raise_error("expected block to perform power, but performed constant")
    end
  end

  context "expect { ... }.not_to perfom_power" do
    it "passes if the block does not perform power" do
      expect { |n| n }.not_to perform_power.in_range(1, 10_000).sample(100)
    end

    it "fails if the block doesn't perform power" do
      range = bench_range(10, 8 << 5)
      numbers = range.map { |n| Array.new(n) { rand(n) } }

      expect {
        expect { |n, i|
          prefix_avg(numbers[i])
        }.not_to perform_power.in_range(range[0], range[-1]).sample(100).times
      }.to raise_error("expected block not to perform power, but performed power")
    end
  end
end
