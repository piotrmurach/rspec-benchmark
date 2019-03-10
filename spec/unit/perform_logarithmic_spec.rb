# frozen_string_literal: true

RSpec.describe 'RSpec::Benchmark::ComplexityMatcher', '#perform_logarithmic' do
  # Iterated logarithm
  # https://en.wikipedia.org/wiki/Iterated_logarithm
  def log_star(n, repeat = 0)
    n <= 1 ? repeat : 1 + log_star(Math.log(n), repeat += 1)
  end

  it "propagates error inside expectation" do
    expect {
      expect { raise 'boom' }.to perform_logarithmic
    }.to raise_error(StandardError, /boom/)
  end

  context "expect { ... }.to perfom_logarithmic" do
    xit "passes if the block performs logarithmic" do
      range = bench_range(1, 8 << 18, ratio: 2)
      numbers = range.map { |n| (1..n).to_a }

      expect { |n, i|
        numbers[i].bsearch { |x| x == 1 }
      }.to perform_log.in_range(range[0], range[-1]).ratio(2).sample(100).times
    end

    it "fails if the block doesn't perform logarithmic" do
      expect {
        expect { |n| n }.to perform_logarithmic.in_range(1, 10_000).sample(100)
      }.to raise_error("expected block to perform logarithmic, but performed constant")
    end
  end

  context "expect { ... }.not_to perfom_logarithmic" do
    it "passes if the block does not perform logarithmic" do
      expect { |n| n }.not_to perform_logarithmic.in_range(1, 10_000).sample(100)
    end

    xit "fails if the block doesn't perform logarithmic" do
      range = bench_range(1, 8 << 18, ratio: 2)
      numbers = range.map { |n| (1..n).to_a }

      expect {
        expect { |n, i|
          numbers[i].bsearch { |x| x == 1 }
        }.not_to perform_log.in_range(range[0], range[-1]).ratio(2).sample(100).times
      }.to raise_error("expected block not to perform logarithmic, but performed logarithmic")
    end
  end
end
