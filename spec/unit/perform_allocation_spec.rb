# frozen_string_literal: true

RSpec.describe "#perform_allocation" do
  context "expect { ... }.to perform_allocation(...)" do
    it "passes if the block performs allocations" do
      expect {
        _a = [Object.new]
      }.to perform_allocation(2)
    end

    it "fails if the block doesn't perform allocation(...)" do
      expect {
        expect {
          _a = [Object.new]
        }.to perform_allocation(1)
      }.to raise_error(/expected block to perform allocation of \d object, but allocated \d objects/)
    end
  end

  context "expect { ... }.not_to perform_allocation(...)" do
    it "passes if the block does not perform allocation" do
      expect {
        ["foo", "bar", "baz"].sort[1]
      }.to_not perform_allocation(2)
    end

    it "fails if the block performs allocation" do
      expect {
        expect {
          _a = [Object.new]
        }.to_not perform_allocation(2)
      }.to raise_error(/expected block not to perform allocation of \d objects, but allocated \d objects/)
    end
  end

  context "expect { ... }.to perform_allocation(Object => ???, ...).objects" do
    it "splits object allocations by count" do
      expect {
        _a = [Object.new]
        _b = {Object.new => 'foo'}
      }.to perform_allocation({Object => 2, Array => 1}).objects
    end

    it "fails to split object allocations by count" do
      expect {
        expect {
          _a = [Object.new]
          _b = {Object.new => 'bar'}
        }.to perform_allocation({Object => 1, Array => 1}).objects
      }.to raise_error("expected block to perform allocation of 1 Array and 1 Object objects, but allocated 1 Array and 2 Object objects")
    end
  end

  context "expect { ... }.not_to perform_allocation(Object => ???, ...).objects" do
    it "passes if the split of object allocations by count is wrong" do
      expect {
        _a = [Object.new]
        _b = {Object.new => 'foo'}
      }.to_not perform_allocation({Object => 1, Array => 1}).objects
    end

    it "fails to split object allocations by count" do
      expect {
        expect {
          _a = [Object.new]
          _b = {Object.new => 'bar'}
        }.to_not perform_allocation({Object => 2, Array => 1}).objects
      }.to raise_error("expected block not to perform allocation of 1 Array and 2 Object objects, but allocated 1 Array and 2 Object objects")
    end
  end

  context "expect { ... }.to perform_allocation(...).bytes" do
    it "passes if the block performs allocations" do
      expect {
        _a = [Object.new]
        _b = {Object.new => 'foo'}
      }.to perform_allocation(600).bytes
    end

    it "fails if the block doesn't perform allocation" do
      expect {
        expect {
          ["foo", "bar", "baz"].sort[1]
        }.to perform_allocation(100).bytes
      }.to raise_error(/expected block to perform allocation of \d+ bytes, but allocated \d+ bytes/)
    end
  end

  context "expect { ... }.not_to perform_allocation(...).bytes" do
    it "passes if the block does not perform allocation" do
      expect {
        ["foo", "bar", "baz"].sort[1]
      }.to_not perform_allocation(100).bytes
    end

    it "fails if the block performs allocation" do
      expect {
        expect {
          _a = [Object.new]
        }.to_not perform_allocation(200).bytes
      }.to raise_error(/expected block not to perform allocation of \d+ bytes, but allocated \d+ bytes/)
    end
  end

  context "expect { ... }.to perform_allocation(Object => ???, ...).bytes" do
    it "splits object allocations by memory size" do
      expect {
        _a = [Object.new]
        _b = {Object.new => 'foo'}
      }.to perform_allocation({Object => 80, Array => 40, Hash => 500}).bytes
    end

    it "fails to split object allocations by memory size" do
      expect {
        expect {
          _a = [Object.new]
          _b = {Object.new => 'bar'}
        }.to perform_allocation({Object => 80, Array => 20}).bytes
      }.to raise_error("expected block to perform allocation of 20 Array and 80 Object bytes, but allocated 40 Array and 80 Object bytes")
    end
  end

  it "fails to recognize expectation type" do
    expect {
      expect { Object.new }.to perform_allocation(:error)
    }.to raise_error(ArgumentError, "'error' is not a recognized argument")
  end
end
