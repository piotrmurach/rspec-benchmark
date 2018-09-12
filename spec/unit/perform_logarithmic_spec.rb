# frozen_string_literal: true

RSpec.describe 'RSpec::Benchmark::ComplexityMatcher', '#perform_logarithmic' do
  # exponential
  def fibonacci(n)
    n < 2 ? n : fibonacci(n - 1) + fibonacci(n - 2)
  end

  it "propagates error inside expectation" do
    expect {
      expect { raise 'boom' }.to perform_logarithmic
    }.to raise_error(StandardError, /boom/)
  end

  context "expect { ... }.to perfom_logarithmic" do
    it "passes if the block performs logarithmic" do
      range = bench_range(1, 8 << 15, ratio: 2)
      arrays_of_numbers = range.map { |n| Array.new(n) { rand(n) } }.each

      expect { |n|
        arrays_of_numbers.next.sum
      }.to perform_logarithmic.within(range[0], range[-1], ratio: 2)
    end

    it "fails if the block doesn't perform logarithmic" do
      expect {
        expect { |n|
          fibonacci(n)
        }.to perform_logarithmic.within(1, 25)
      }.to raise_error("expected block to perform logarithmic, but performed exponential")
    end
  end

  context "expect { ... }.not_to perfom_logarithmic" do
    it "passes if the block does not perform logarithmic" do
      expect { |n|
        fibonacci(n)
      }.not_to perform_logarithmic.within(1, 25)
    end

    it "fails if the block doesn't perform logarithmic" do
      range = bench_range(1, 8 << 15, ratio: 2)
      arrays_of_numbers = range.map { |n| Array.new(n) { rand(n) } }.each

      expect {
        expect { |n|
          arrays_of_numbers.next.sum
        }.not_to perform_logarithmic.within(range[0], range[-1], ratio: 2)
      }.to raise_error("expected block not to perform logarithmic, but performed logarithmic")
    end
  end
end
