# frozen_string_literal: true

RSpec.describe 'RSpec::Benchmark::ComplexityMatcher', '#perform_constant' do
  # exponential
  def fibonacci(n)
    n < 2 ? n : fibonacci(n - 1) + fibonacci(n - 2)
  end

  it "propagates error inside expectation" do
    expect {
      expect { raise 'boom' }.to perform_constant
    }.to raise_error(StandardError, /boom/)
  end

  context "expect { ... }.to perfom_constant" do
    it "passes if the block performs constant" do
      expect { |n, i|
        n * i
      }.to perform_constant.within(1, 1000).sample(100)
    end

    it "fails if the block doesn't perform constant" do
      expect {
        expect { |n, i|
          fibonacci(n)
        }.to perform_constant.within(1, 15, ratio: 2).sample(100)
      }.to raise_error("expected block to perform constant, but performed exponential")
    end
  end

  context "expect { ... }.not_to perfom_constant" do
    it "passes if the block does not perform constant" do
      expect { |n, i|
        fibonacci(n)
      }.not_to perform_constant.within(1, 15, ratio: 2).sample(100)
    end

    it "fails if the block doesn't perform constant" do
      expect {
        expect { |n, i|
          n * i
        }.not_to perform_constant.within(1, 1000).sample(100)
      }.to raise_error("expected block not to perform constant, but performed constant")
    end
  end
end
