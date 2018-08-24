# frozen_string_literal: true

RSpec.describe 'composable specs' do
  it "composes perform_under and perform_at_least matchers" do
    expect { 
      'x' * 1024 * 10
    }.to perform_under(6).ms and perform_at_least(10_000).ips
  end
end
