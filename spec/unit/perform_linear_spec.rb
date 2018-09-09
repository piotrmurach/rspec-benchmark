# frozen_string_literal: true

RSpec.describe 'RSpec::Benchmark::ComplexityMatcher', '#perform_linear' do
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
          'x' * 1024 * 10 * (n ** 2)
        }.to perform_linear.within(1, 150)
      }.to raise_error("expected block to perform linear, but performed power")
    end
  end

  context "expect { ... }.not_to perfom_linear" do
    it "passes if the block does not perform linear" do
      expect { |n|
        'x' * 1024 * 10 * (n ** 2)
      }.not_to perform_linear.within(1, 150)
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
