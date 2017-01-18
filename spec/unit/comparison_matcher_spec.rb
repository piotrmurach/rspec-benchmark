# encoding: utf-8

RSpec.describe 'RSpec::Benchmark::ComparisonMatcher' do
  describe '#perform_faster_than' do
    context "expect { ... }.to perform_faster_than(...)" do
      it "passes if the block performs faster than sample" do
        expect {
          1 << 1
        }.to perform_faster_than { 'x' * 10 }
      end

      it "fails if the block performs slower than sample" do
        expect {
          expect {
            'x' * 10
          }.to perform_faster_than { 1 << 1 }
        }.to raise_error(/expected block to perform faster than passed block, but performed slower in \d+.\d+ times/)
      end
    end

    context "expect { ... }.to perform_faster_than(...).in(...).times" do
      it "passes if the block performs faster than sample" do
        expect {
          1 << 1
        }.to perform_faster_than { 'x' * 10 }.in(2).times
      end

      it "fails if the block performs faster than sample" do
        expect {
          expect {
            'x' * 10
          }.to perform_faster_than { 1 << 1 }.in(5).times
        }.to raise_error(/expected block to perform faster than passed block in \d+ times, but performed slower in \d+.\d+ times/)
      end
    end

    context "expect { ... }.not_to perform_faster_than(...)" do
      it "passes if the block performs slower than sample" do
        expect {
          'x' * 10
        }.not_to perform_faster_than { 1 << 1 }
      end

      it "fails if the block performs faster than sample" do
        expect {
          expect {
            1 << 1
          }.not_to perform_faster_than { 'x' * 10 }
        }.to raise_error(/expected block not to perform faster than passed block, but performed faster in \d+.\d+ times/)
      end
    end

    context "expect { ... }.not_to perform_faster_than(...).in(...).times" do
      it "passes if the block performs slower than sample" do
        expect {
          'x' * 10
        }.not_to perform_faster_than { 1 << 1 }.in(20).times
      end

      it "fails if the block performs faster than sample" do
        expect {
          expect {
            1 << 1
          }.not_to perform_faster_than { 'x' * 10 }.in(2).times
        }.to raise_error(/expected block not to perform faster than passed block in \d+ times, but performed faster in \d+.\d+ times/)
      end
    end
  end

  describe '#perform_slower_than' do
    context "expect { ... }.not_to perform_slower_than(...)" do
      it "passes if the block performs faster than sample" do
        expect {
          1 << 1
        }.not_to perform_slower_than { 'x' * 10 }
      end

      it "fails if the block performs slower than sample" do
        expect {
          expect {
            'x' * 10
          }.not_to perform_slower_than { 1 << 1 }
        }.to raise_error(/expected block not to perform slower than passed block, but performed slower in \d+.\d+ times/)
      end
    end

    context "expect { ... }.not_to perform_slower_than(...).in(...).times" do
      it "passes if the block performs faster than sample" do
        expect {
          1 << 1
        }.not_to perform_slower_than { 'x' * 10 }.in(2).times
      end

      it "fails if the block performs slower than sample" do
        expect {
          expect {
            'x' * 10
          }.not_to perform_slower_than { 1 << 1 }.in(5).times
        }.to raise_error(/expected block not to perform slower than passed block in \d+ times, but performed slower in \d+.\d+ times/)
      end
    end

    context "expect { ... }.not_to perform_slower_than(...)" do
      it "passes if the block performs slower than sample" do
        expect {
          'x' * 10
        }.to perform_slower_than { 1 << 1 }
      end

      it "fails if the block performs faster than sample" do
        expect {
          expect {
            1 << 1
          }.to perform_slower_than { 'x' * 10 }
        }.to raise_error(/expected block to perform slower than passed block, but performed faster in \d+.\d+ times/)
      end
    end

    context "expect { ... }.not_to perform_slower_than(...).in(...).times" do
      it "passes if the block does performs slower than sample" do
        expect {
          'x' * 10
        }.to perform_slower_than { 1 << 1 }.in(20).times
      end

      it "fails if the block does performs faster than sample" do
        expect {
          expect {
            1 << 1
          }.to perform_slower_than { 'x' * 10 }.in(2).times
        }.to raise_error(/expected block to perform slower than passed block in \d+ times, but performed faster in \d+.\d+ times/)
      end
    end
  end
end