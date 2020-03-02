# frozen_string_literal: true

RSpec.describe RSpec::Benchmark, "#format_time" do
  {
    1e-10   => "0 ns",
    0.42e-6 => "420 ns",
    # us
    3.4e-6  => "3.4 μs",
    34e-6   => "34 μs",
    340e-6  => "340 μs",
    # ms
    0.001   => "1 ms",
    0.0123  => "12.3 ms",
    0.123   => "123 ms",
    0.1     => "100 ms",
    # sec
    1.0     => "1 sec",
    1.2345  => "1.23 sec",
    12.123  => "12.1 sec",
    123.45  => "123 sec",
    1234    => "1234 sec",
    1234.56 => "1235 sec"
  }.each do |input, expected|
    it "#{input} -> #{expected}" do
      expect(described_class.format_time(input)).to eq(expected)
    end
  end
end
