class Hash
  def rmerge!(other_hash)
    merge!(other_hash) do |key, oldval, newval|
      if oldval.is_a?(SimpleConf::Conf) && newval.is_a?(SimpleConf::Conf)
        oldval.check_and_change_overrides(newval)
        oldval.__vars__.rmerge!(newval.__vars__)
        oldval.instance_eval(&newval.__instance_block__)
        oldval
      elsif oldval.is_a?(Hash)
        oldval.rmerge!(newval)
      else
        newval
      end
    end
  end
end
