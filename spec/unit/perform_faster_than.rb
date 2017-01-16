# encoding: utf-8

RSpec.describe '#perform_faster_than' do

  context "expect { ... }.to perform_faster_than(...)" do
    it "passes if the block perform faster than sample" do
      expect {
        1 << 1
      }.to perform_faster_than { 'x' * 1024 * 10 }
    end

    it "fails if the sample perform faster than block" do
      expect {
        expect {
          'x' * 1024 * 10
        }.to perform_faster_than { 1 << 1 }
      }.to raise_error(/expected block to perform faster than passed block, but performed slower in \d+ times/)
    end
  end

  context "expect { ... }.to perform_faster_than(...).in(...).times" do
    it "passes if the block perform faster than sample" do
      expect {
        1 << 1
      }.to perform_faster_than { 'x' * 1024 * 10 }.in(5).times
    end

    it "fails if the sample perform faster than block" do
      expect {
        expect {
          'x' * 1024 * 10
        }.to perform_faster_than { 1 << 1 }.in(5).times
      }.to raise_error(/expected block to perform faster than passed block in \d+ times, but performed slower in \d+ times/)
    end
  end

  context "expect { ... }.not_to perform_faster_than(...)" do
    it "passes if the block does not perform faster than sample" do
      expect {
        'x' * 1024 * 10
      }.not_to perform_faster_than { 1 << 1 }
    end

    it "fails if the sample does not perform faster than block" do
      expect {
        expect {
          1 << 1
        }.not_to perform_faster_than { 'x' * 1024 * 10 }
      }.to raise_error(/expected block not to perform faster than passed block, but performed faster in \d+ times/)
    end
  end

  context "expect { ... }.not_to perform_faster_than(...).in(...).times" do
    it "passes if the block does not perform faster than sample" do
      expect {
        'x' * 1024 * 10
      }.not_to perform_faster_than { 1 << 1 }.in(5).times
    end

    it "fails if the sample  does not perform faster than block" do
      expect {
        expect {
          1 << 1
        }.not_to perform_faster_than { 'x' * 1024 * 10 }.in(5).times
      }.to raise_error(/expected block not to perform faster than passed block in \d+ times, but performed faster in \d+ times/)
    end
  end
end
