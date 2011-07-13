module SimpleConf
  require 'simpleconf/blank_slate'
  require 'simpleconf/conf'

  def build(opts={}, &blk)
    fail "Build needs a block" unless block_given?
    c = Conf.new(opts)
    c.instance_eval(&blk)
    c.init_only = true if opts[:init_only]
    c
  end

  module_function :build
end
