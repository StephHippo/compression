require 'stringio'

module Kernel
  def capture_stdout &block
    old_stdout = $stdout
    fake_stdout = StringIO.new
    $stdout = fake_stdout
    block.call
    fake_stdout.string
  ensure
    $stdout = old_stdout
  end
end