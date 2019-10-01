# frozen_string_literal: true

RSpec.configure do |c|
  c.before :suite do
    run_shell('puppet module install puppet-archive')
  end
end
