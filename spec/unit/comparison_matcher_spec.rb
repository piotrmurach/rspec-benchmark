# frozen_string_literal: true

RSpec.describe RSpec::Benchmark::ComparisonMatcher::Matcher do

  it "validates comparison type" do
    expect {
      described_class.new(-> { 1 + 2 }, :unknown)
    }.to raise_error(ArgumentError, /comparison_type must be :faster or :slower, not `:unknown`/)
  end

  it "raises expectation error when not given a block" do
    expect {
      expect(1 + 1).to perform_faster_than { 'x' * 10 * 1024 }
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
    "expected given block to perform faster than comparison block, but was not a block")
  end

  it "allows to configure matcher timings" do
    allow(::Benchmark::Perf::Iteration).to receive(:run).and_return(100)

    expect {
      1 << 1
    }.to perform_faster_than.within(0.3).warmup(0.2) {
      'x' * 10 * 1024
    }.once

    expect(::Benchmark::Perf::Iteration).to have_received(:run).with(time: 0.3, warmup: 0.2).twice
  end

  context 'algorithms comparison' do
    def clamp(num, min, max)
      [num, min, max].sort[1]
    end

    def clamp_fast(num, min, max)
      num > max ? max : (num < min ? min : num)
    end

    it "infers one implementation faster than another" do
      num = rand(1_000)
      expect {
        clamp_fast(num, num / 2, num * 2)
      }.to perform_faster_than {
        clamp(num, num / 2, num * 2)
      }.at_least(1.5).times
    end
  end

  describe "expect { ... }.to perform_faster_than(...)" do
    it "passes if the block performs faster than sample" do
      expect { 1 << 1 }.to perform_faster_than { 'x' * 10 * 1024 }
    end

    it "fails if the block performs slower than sample" do
      expect {
        expect { 'x' * 10 * 1024 }.to perform_faster_than { 1 << 1 }
      }.to raise_error(/expected given block to perform faster than comparison block, but performed slower by \d+.\d+ times/)
    end

    context 'with exact count' do
      it "passes if the block performs faster than sample" do
        expect { 1 << 1 }.to perform_faster_than { 1 << 1 }.exactly(1).times
      end

      it "passes if the block performs specified number of times" do
        expect { 1 << 1 }.to perform_faster_than { 1 << 1 }.once
      end
    end

    context "with at_least count" do
      it "passes if the block performs faster by count times" do
        expect { 1 << 1 }.to perform_faster_than { 'x' * 10 * 1024 }.at_least(2)
      end

      it "fails if the block doesn't perform faster by count times" do
        expect {
          expect {
            'x' * 10 * 1024
          }.to perform_faster_than { 1 << 1 }.at_least(2).times
        }.to raise_error(/expected given block to perform faster than comparison block by at_least \d+ times, but performed slower by \d+.\d+ times/)
      end
    end

    context "with at_most count" do
      it "passes if the block performs faster than sample" do
        expect { 1 << 1 }.to perform_faster_than { 'x' * 10 * 1024 }.at_most(125)
      end

      it "fails if the block performs faster than sample more than in 20 times" do
        expect {
          expect {
            1 << 1
          }.to perform_faster_than { 'x' * 10 * 1024 }.at_most(2).times
        }.to raise_error(/expected given block to perform faster than comparison block by at_most \d+ times, but performed faster by \d+.\d+ times/)
      end
    end
  end

  context "expect { ... }.not_to perform_faster_than(...)" do
    it "passes if the block performs slower than sample" do
      expect { 'x' * 10 * 1024 }.not_to perform_faster_than { 1 << 1 }
    end

    it "fails if the block performs faster than sample" do
      expect {
        expect { 1 << 1 }.not_to perform_faster_than { 'x' * 10 * 1024 }
      }.to raise_error(/expected given block not to perform faster than comparison block, but performed faster by \d+.\d+ times/)
    end

    context 'with at_least count' do
      it "passes if the block performs slower than sample" do
        expect {
          'x' * 10 * 1024
        }.not_to perform_faster_than { 1 << 1 }.at_least(20).times
      end

      it "fails if the block performs faster than sample" do
        expect {
          expect {
            1 << 1
          }.not_to perform_faster_than { 'x' * 10 * 1024 }.at_least(2).times
        }.to raise_error(/expected given block not to perform faster than comparison block by at_least \d+ times, but performed faster by \d+.\d+ times/)
      end
    end
  end

  describe "expect { ... }.not_to perform_slower_than(...)" do
    it "passes if the block performs faster than sample" do
      expect { 1 << 1 }.not_to perform_slower_than { 'x' * 10 * 1024 }
    end

    it "fails if the block performs slower than sample" do
      expect {
        expect { 'x' * 10 * 1024 }.not_to perform_slower_than { 1 << 1 }
      }.to raise_error(/expected given block not to perform slower than comparison block, but performed slower by \d+.\d+ times/)
    end

    context "with at_least count" do
      it "passes if the block performs faster than sample" do
        expect {
          1 << 1
        }.not_to perform_slower_than { 'x' * 10 * 1024 }.at_least(2).times
      end

      it "fails if the block performs slower than sample" do
        expect {
          expect {
            'x' * 10 * 1024
          }.not_to perform_slower_than { 1 << 1 }.at_least(5).times
        }.to raise_error(/expected given block not to perform slower than comparison block by at_least \d+ times, but performed slower by \d+.\d+ times/)
      end
    end
  end

  describe "expect { ... }.to perform_slower_than(...)" do
    it "passes if the block performs slower than sample" do
      expect { 'x' * 10 * 1024 }.to perform_slower_than { 1 << 1 }
    end

    it "fails if the block performs faster than sample" do
      expect {
        expect { 1 << 1 }.to perform_slower_than { 'x' * 10 * 1024 }
      }.to raise_error(/expected given block to perform slower than comparison block, but performed faster by \d+.\d+ times/)
    end

    context "with at_least count" do
      it "passes if the block does performs slower than sample" do
        expect {
          'x' * 10 * 1024
        }.to perform_slower_than { 1 << 1 }.at_least(20).times
      end

      it "fails if the block count compared with sample is too high" do
        expect {
          expect {
            'x' * 10 * 1024
          }.to perform_slower_than { 1 << 1 }.at_least(200).times
        }.to raise_error(/expected given block to perform slower than comparison block by at_least 200 times, but performed slower by \d+.\d+ time/)
      end

      it "fails if the block does perform faster than sample" do
        expect {
          expect {
            1 << 1
          }.to perform_slower_than { 'x' * 10 * 1024 }.at_least(2).times
        }.to raise_error(/expected given block to perform slower than comparison block by at_least \d+ times, but performed faster by \d+.\d+ times/)
      end
    end

    context "with exact count" do
      it "passes if the block performs slower than sample" do
        expect { 1 << 1 }.to perform_slower_than { 1 << 1 }.exactly(1).times
      end
    end

    context "with at_most count" do
      it "passes if the block performs faster than sample" do
        expect {
          'x' * 10 * 1024
        }.to perform_slower_than { 1 << 1 }.at_most(125).times
      end

      it "fails if the block performs slower than sample more than in 20 times" do
        expect {
          expect {
            'x' * 10 * 1024
          }.to perform_slower_than { 1 << 1 }.at_most(2).times
        }.to raise_error(/expected given block to perform slower than comparison block by at_most \d+ times, but performed slower by \d+.\d+ times/)
      end
    end
  end
end
