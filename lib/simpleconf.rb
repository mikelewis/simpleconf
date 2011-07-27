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

  def build_from_string(instance_str, opts={})
    c = Conf.new(instance_str, opts)
    c.instance_eval(instance_str)
    c.__init_only__ = true if opts[:init_only]
    c
  end

  def load(file_name, opts={})
    build_from_string(File.read(file_name), opts)
  end

  module_function :build, :build_from_string, :load

end
