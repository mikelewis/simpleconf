$:.unshift File.dirname(__FILE__) + '/../lib'

require 'simpleconf'

a = SimpleConf.build do
  bear "blah"
  yessir "YUS"
end

p a.bear
a.bear "hahaha"
p a.bear
