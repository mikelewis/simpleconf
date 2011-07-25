module SimpleConf
  class Conf < ::BlankSlate
    attr_accessor :__vars__,  :__init_only__
    attr_reader :__instance_block__, :__overrides__
    def initialize(instance_block, opts={})
      @__opts__ = opts
      @__vars__ = {}
      @__init_only__ = false
      @__instance_block__ = instance_block
      @__default_config__ = {
        :override => true
      }

      @__overrides__ = {}
    end

    def merge(other)
      fail "Other needs to be a SimpleConf::Conf" unless other.is_a? Conf
      copy = SimpleConf.build(@__opts__, &@__instance_block__)
      copy.merge!(other)
      copy
    end

    def check_and_change_overrides(other)
      self.__overrides__.each do |meth, override|
        if !override
          other.__overrides__[meth] = false
          other.__vars__[meth] = __vars__[meth]
        end
      end

    end

    def merge!(other)
      fail "Other needs to be a SimpleConf::Conf" unless other.is_a? Conf
      check_and_change_overrides(other)
      self.__init_only__ = other.__init_only__
      self.instance_eval(&other.__instance_block__)
      __vars__.rmerge!(other.__vars__)
      nil
    end

    def method_missing(meth, *args, &blk)
      fail "#{meth} was not defined in configuration setup" if @__init_only__

      meta = (class << self; self; end)

      if block_given?
        nested_opts = @__opts__.merge(args.shift || {})
        sub_config = SimpleConf.build(nested_opts, &blk)

        meta.class_eval do
          define_method(meth) do |*args, &blk|
          @__vars__[meth]
          end
        end
        @__vars__[meth] = sub_config
        return
      end

      value = args.shift
      opts = @__default_config__.merge(args.shift || {})
      @__overrides__[meth] = opts[:override]
      meta.class_eval do
        define_method(meth) do |*args, &blk|
          local_override = ((args[1].is_a?(Hash) && !args[1][:override].nil?)   && @__overrides__[meth]) ? args[1][:override] : @__overrides__[meth]

          @__overrides__[meth] = local_override

          if args.first && @__overrides__[meth]
            @__vars__[meth] = args.first
          else
            @__vars__[meth]
          end
        end

        define_method("#{meth}=") do |*args|
          if args.first && @__overrides__[meth]
            @__vars__[meth] = args.first
          end
          @__vars__[meth]
        end
      end
      @__vars__[meth] = value
  end
end
end
