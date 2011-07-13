module SimpleConf
  class Conf < BlankSlate
    attr_writer :init_only
    def initialize(opts={})
      @vars = {}
      @init_only = false
      @default_config = {
        :override => true
      }
    end

    def method_missing(meth, *args, &blk)
      fail "#{meth} was not defined in configuration setup" if @init_only
      meta = class << self; self; end
      value = args.shift
      opts = @default_config.merge(args.shift || {})
      meta.class_eval do
        define_method(meth) do |*args, &blk|
          if args.first && opts[:override]
            @vars[meth] = args.first
          else
            @vars[meth]
          end
        end

        define_method("#{meth}=") do |*args|
          if args.first && opts[:override]
            @vars[meth] = args.first
          end
          @vars[meth]
        end
      end
      @vars[meth] = value
    end
  end
end
