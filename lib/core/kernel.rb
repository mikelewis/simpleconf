module Kernel
  def SimpleConf(*args, &blk)
    SimpleConf.build(*args, &blk)
  end
end
