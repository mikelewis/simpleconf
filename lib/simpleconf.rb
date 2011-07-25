module SimpleConf
  require 'blankslate'
  BlankSlate.reveal(:is_a?)
  require 'simpleconf/conf'
  require 'core/hash'
  require 'core/kernel'

  def build(opts={}, &blk)
    fail "Build needs a block" unless block_given?
    c = Conf.new(blk, opts)
    c.instance_eval(&blk)
    c.__init_only__ = true if opts[:init_only]
    c
  end

  module_function :build

end

