module SimpleConf
  class BlankSlate
    instance_methods.each { |m| undef_method m unless m =~ /^__|instance_eval/ }
  end    
end
