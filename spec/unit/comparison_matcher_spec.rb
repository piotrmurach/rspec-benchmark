# encoding: utf-8

RSpec.describe RSpec::Benchmark::ComparisonMatcher::Matcher do

  it "validates comparison type" do
    expect {
      described_class.new(-> { 1 + 2 }, :unknown)
    }.to raise_error(ArgumentError, /comparison_type must be :faster or :slower, not `:unknown`/)
  end

  describe '#perform_faster_than' do
    context "expect { ... }.to perform_faster_than(...)" do
      it "passes if the block performs faster than sample" do
        expect {
           1 << 1
        }.to perform_faster_than { 'x' * 10 * 1024 }
      end

      it "fails if the block performs slower than sample" do
        expect {
          expect {
            'x' * 10 * 1024
          }.to perform_faster_than { 1 << 1 }
        }.to raise_error(/expected block to perform faster than passed block, but performed slower in \d+.\d+ times/)
      end
    end

    context "expect { ... }.to perform_faster_than(...).at_least(...).times" do
      it "passes if the block performs faster than sample" do
        expect {
          1 << 1
        }.to perform_faster_than { 'x' * 10 * 1024 }.at_least(2).times
      end

      it "fails if the block performs faster than sample" do
        expect {
          expect {
            'x' * 10 * 1024
          }.to perform_faster_than { 1 << 1 }.at_least(5).times
        }.to raise_error(/expected block to perform faster than passed block at_least in \d+ times, but performed slower in \d+.\d+ times/)
      end
    end

    context "expect { ... }.not_to perform_faster_than(...)" do
      it "passes if the block performs slower than sample" do
        expect {
          'x' * 10 * 1024
        }.not_to perform_faster_than { 1 << 1 }
      end

      it "fails if the block performs faster than sample" do
        expect {
          expect {
            1 << 1
          }.not_to perform_faster_than { 'x' * 10 * 1024 }
        }.to raise_error(/expected block not to perform faster than passed block, but performed faster in \d+.\d+ times/)
      end
    end

    context "expect { ... }.not_to perform_faster_than(...).at_least(...).times" do
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
        }.to raise_error(/expected block not to perform faster than passed block at_least in \d+ times, but performed faster in \d+.\d+ times/)
      end
    end

    context "expect { ... }.to perform_faster_than.{ ... }.exactly(...).times" do
      it "passes if the block performs faster than sample" do
        expect {
          1 << 1
        }.to perform_faster_than { 1 << 1 }.exactly(1).times
      end
    end

    context "expect { ... }.to perform_faster_than.{ ... }.at_most(...).times" do
      it "passes if the block performs faster than sample" do
        expect {
          1 << 1
        }.to perform_faster_than { 'x' * 10 * 1024 }.at_most(125).times
      end

      it "fails if the block performs faster than sample more than in 20 times" do
        expect {
          expect {
            1 << 1
          }.to perform_faster_than { 'x' * 10 * 1024 }.at_most(10).times
        }.to raise_error(/expected block to perform faster than passed block at_most in \d+ times, but performed faster in \d+.\d+ times/)
      end
    end
  end

  describe '#perform_slower_than' do
    context "expect { ... }.not_to perform_slower_than(...)" do
      it "passes if the block performs faster than sample" do
        expect {
          1 << 1
        }.not_to perform_slower_than { 'x' * 10 * 1024 }
      end

      it "fails if the block performs slower than sample" do
        expect {
          expect {
            'x' * 10 * 1024
          }.not_to perform_slower_than { 1 << 1 }
        }.to raise_error(/expected block not to perform slower than passed block, but performed slower in \d+.\d+ times/)
      end
    end

    context "expect { ... }.not_to perform_slower_than(...).at_least(...).times" do
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
        }.to raise_error(/expected block not to perform slower than passed block at_least in \d+ times, but performed slower in \d+.\d+ times/)
      end
    end

    context "expect { ... }.not_to perform_slower_than(...)" do
      it "passes if the block performs slower than sample" do
        expect {
          'x' * 10 * 1024
        }.to perform_slower_than { 1 << 1 }
      end

      it "fails if the block performs faster than sample" do
        expect {
          expect {
            1 << 1
          }.to perform_slower_than { 'x' * 10 * 1024 }
        }.to raise_error(/expected block to perform slower than passed block, but performed faster in \d+.\d+ times/)
      end
    end

    context "expect { ... }.not_to perform_slower_than(...).at_least(...).times" do
      it "passes if the block does performs slower than sample" do
        expect {
          'x' * 10 * 1024
        }.to perform_slower_than { 1 << 1 }.at_least(20).times
      end

      it "fails if the block does performs faster than sample" do
        expect {
          expect {
            1 << 1
          }.to perform_slower_than { 'x' * 10 * 1024 }.at_least(2).times
        }.to raise_error(/expected block to perform slower than passed block at_least in \d+ times, but performed faster in \d+.\d+ times/)
      end
    end

    context "expect { ... }.to perform_slower_than.{ ... }.exactly(...).times" do
      it "passes if the block performs slower than sample" do
        expect {
          1 << 1
        }.to perform_slower_than { 1 << 1 }.exactly(1).times
      end
    end

    context "expect { ... }.to perform_slower_than.{ ... }.at_most(...).times" do
      it "passes if the block performs faster than sample" do
        expect {
          'x' * 10 * 1024
        }.to perform_slower_than { 1 << 1 }.at_most(125).times
      end

      it "fails if the block performs slower than sample more than in 20 times" do
        expect {
          expect {
            'x' * 10 * 1024
          }.to perform_slower_than { 1 << 1 }.at_most(10).times
        }.to raise_error(/expected block to perform slower than passed block at_most in \d+ times, but performed slower in \d+.\d+ times/)
      end
    end
  end
end
