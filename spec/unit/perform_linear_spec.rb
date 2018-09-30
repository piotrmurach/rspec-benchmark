# frozen_string_literal: true

RSpec.describe 'RSpec::Benchmark::ComplexityMatcher', '#perform_linear' do
  # exponential
  def fibonacci(n)
    n < 2 ? n : fibonacci(n - 1) + fibonacci(n - 2)
  end

  it "propagates error inside expectation" do
    expect {
      expect { raise 'boom' }.to perform_linear
    }.to raise_error(StandardError, /boom/)
  end

  context "expect { ... }.to perfom_linear" do
    it "passes if the block performs linear" do
      range = bench_range(1, 8 << 10)
      numbers = range.map { |n| Array.new(n) { rand(n) } }

      expect { |n, i|
        numbers[i].max
      }.to perform_linear.within(range[0], range[-1]).sample(100)
    end

    it "fails if the block doesn't perform linear" do
      expect {
        expect { |n, i|
          fibonacci(n)
        }.to perform_linear.within(1, 18, ratio: 2).sample(100)
      }.to raise_error("expected block to perform linear, but performed exponential")
    end
  end

  context "expect { ... }.not_to perfom_linear" do
    it "passes if the block does not perform linear" do
      expect { |n, i|
        fibonacci(n)
      }.not_to perform_linear.within(1, 18, ratio: 2).sample(100)
    end

    it "fails if the block doesn't perform linear" do
      range = bench_range(10, 8 << 12)
      numbers = range.map { |n| Array.new(n) { rand(n) } }

      expect {
        expect { |n, i|
          numbers[i].max
        }.not_to perform_linear.within(range[0], range[-1]).sample(100)
      }.to raise_error("expected block not to perform linear, but performed linear")
    end
  end
end
