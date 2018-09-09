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
      expect { |n|
        'x' * 1024 * 10
      }.to perform_linear.within(8, 8 << 20)
    end

    it "fails if the block doesn't perform linear" do
      expect {
        expect { |n|
          fibonacci(n)
        }.to perform_linear.within(1, 25)
      }.to raise_error("expected block to perform linear, but performed exponential")
    end
  end

  context "expect { ... }.not_to perfom_linear" do
    it "passes if the block does not perform linear" do
      expect { |n|
        fibonacci(n)
      }.not_to perform_linear.within(1, 25)
    end

    it "fails if the block doesn't perform linear" do
      expect {
        expect { |n|
          'x' * 1024 * 10
        }.not_to perform_linear.within(1, 100)
      }.to raise_error("expected block not to perform linear, but performed linear")
    end
  end
end
