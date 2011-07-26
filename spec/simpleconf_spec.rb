require 'spec_helper'

describe SimpleConf do
  context "#build" do
    it "should respond to build" do
      SimpleConf.should respond_to(:build)
    end

    it "should throw an error if no block given" do
      lambda {
        SimpleConf.build
      }.should raise_error
    end

    it "should accept a block" do
      lambda {
        SimpleConf.build {}
      }.should_not raise_error
    end

    it "should return a SimpleConf::Conf" do
      SimpleConf.build{}.should be_an_instance_of(SimpleConf::Conf)
    end

    it "should return two seperate configs for two calls" do
      c = SimpleConf.build {}
      SimpleConf.build{}.should_not eq(c)
    end
  end

  it "should create a Kernel method SimpleConf" do
    Kernel.should respond_to(:SimpleConf)
  end

  it "should of created a recursive merge for hash" do
    meth_name = RUBY_VERSION < "1.9" ? "rmerge!" : :rmerge!
    Hash.instance_methods.should include(meth_name)
  end

  it "should create a Kernel method that works" do
    c = SimpleConf {
      boat "blue"
      sky "red"
    }
    c.boat.should == "blue"
    c.sky.should == "red"
  end

  it "should be able to create simple config" do
    c = SimpleConf.build do
      host "localhost"
      port 80
      this_is_blank
    end

    c.host.should  == "localhost"
    c.port.should == 80
    c.this_is_blank.should == nil
  end

  it "should be able to create a simple config that we can edit" do
    c = SimpleConf.build do
      host "localhost"
    end
    c.host "google.com"

    c.host.should == "google.com"
  end

  it "should be able to respond to value= after setup" do
    c = SimpleConf.build do
      host "localhost"
    end
    c.host = "google.com"
    c.host.should == "google.com"
  end

  context "Blank Slate" do
    it "should remove all methods and allow user to do whatever he wants " do
      
    c = SimpleConf {
      id 5
      hash 20
      freeze "boo"
    }

    c.id.should == 5
    c.hash.should == 20
    c.freeze.should == "boo"
    end

  end

  context "init_only" do
    it "should throw an error if we use strict option and we have never encountered that config item" do
      c = SimpleConf.build :init_only => true do
        host "localhost"
      end
      lambda {
        c.port
      }.should raise_error
    end

    it "should throw an error if we use the strict options and we try to make another config" do
      c = SimpleConf(:init_only=>true) {
        host "localhost"
      }

      lambda {
      c.port "boooo"
      }.should raise_error
    end

    it "should not throw an error if we don't use strict option and we have never enounterd that config item" do
      c = SimpleConf.build do
        host "localhost"
      end
      lambda {
        c.port
      }.should_not raise_error
    end
  end

  context "override" do
    it "should default to true" do
      c = SimpleConf.build do
        host "localhost"
      end

      c.host "yea"
      c.host.should == "yea"
    end

    it "should not allow override if specified" do
      c = SimpleConf.build do
        host "localhost", :override => false
      end

      c.host "bo"
      c.host = "HAHAHA"
      c.host.should == "localhost"
    end
  end

  context "nested" do
    it "should create nested configs" do
      c = SimpleConf {
        server {
        host "localhost"
        port 80
      }
      }

      c.server.should respond_to(:host)
      c.server.should respond_to(:port)
      c.server.host.should == "localhost"
      c.server.port.should == 80
    end

    it "should create nested configs forever" do
      c = SimpleConf {
        a {
        age 15
        b {
          name "Mike"
          c {
            d 5
          }
        }
      }
      }

      c.a.age.should == 15
      c.a.b.name.should == "Mike"
      c.a.b.c.d.should == 5
    end

    it "should be able to access the nested namespace" do
      c = SimpleConf {
        server {
          host "localhost"
          port 80
        }
      }

      lambda { c.server }.should_not raise_error
      c.server.should be_an_instance_of(SimpleConf::Conf)
      p c.server
      c.server.host.should == "localhost"
      c.server.port.should == 80
    end

    it "should allow for editable config elems within nests" do
      c = SimpleConf {
        a {
        b {
        name "mike"
      }
      }
      }
      c.a.b.name = "Tim"

      c.a.b.name.should == "Tim"
    end

    it "should inherit properties" do
      c = SimpleConf(:init_only => true) {
        a {
        age 15
      }
      }
      c.a.age 20

      lambda {
        c.a.b
      }.should raise_error
    end

    it "should allow for options for nests" do
      c = SimpleConf {
        age 15
        a(:init_only=>true) {
          name "Mike"

          b {
            sex "male"
            race "human", :override => false
          }
        }
      }

      lambda { c.a.tom }.should raise_error

        c.age 20
      c.age.should == 20

      lambda { c.a.b.haha }.should raise_error

        c.a.b.race "donkey"
      c.a.b.race.should == "human"

      c.a.b.sex "female"
      c.a.b.sex.should == "female"
    end

    it "should allow for options within nests" do
      c = SimpleConf {
        a {
        b "Mike", :override => false
      }
      }

      c.a.b "Tom"
      c.a.b.should == "Mike"
    end
  end

  context "Merge" do
    before do
      @default = SimpleConf {
        server "localhost"
        port 80
        socket "/tmp/sock.sock"

        tree {
          leafs 30
          height 50
          bugs false
          ants{
            big false
            fast true
          }
        }
      }

      @new = SimpleConf {
        port 90
        socket "haha"
        tree {
          leafs 60, :override => false
          bugs true
          ants {
            fast false
            home {
              big true
              sq_feet 5000
            }
          }
        }
      }
    end

    it "Conf should respond to merge and merge!" do
      c = SimpleConf {
        a "b"
      }
      [:merge, :merge!].each do |meth|
        c.should respond_to(meth)
      end
    end

    it "should not accept anything other than another SimpleConf::Conf object" do
      c = SimpleConf {
        server "localhost"
      }
      lambda {
        c.merge!(5)
      }.should raise_error
    end

    it "should merge! a SimpleConf::Conf" do

      ret_val = @default.merge!(@new)

      ret_val.should be_nil
      @default.should be_an_instance_of(SimpleConf::Conf)

      @default.server.should == "localhost"
      @default.port.should == 90
      @default.socket.should == "haha"
      @default.tree.bugs.should == true
      @default.tree.leafs.should == 60
      @default.tree.height.should == 50
      @default.tree.ants.big.should == false
      @default.tree.ants.home.sq_feet.should == 5000
    end

    it "should merge a SimpleConf::Conf" do

      new_conf = @default.merge(@new)

      new_conf.should be_an_instance_of(SimpleConf::Conf)
      new_conf.should_not eq(@default)

      new_conf.server.should == "localhost"
      new_conf.port.should == 90
      new_conf.socket.should == "haha"
      new_conf.tree.bugs.should == true
      new_conf.tree.leafs.should == 60
      new_conf.tree.height.should == 50
      new_conf.tree.ants.big.should == false
      new_conf.tree.ants.home.sq_feet.should == 5000
    end

    it "should merge a SimpleConf::Conf and leave the old one intact" do
      new_conf = @default.merge(@new)

      @default.server.should == "localhost"
      @default.port == 80
      @default.tree.leafs == 30
      @default.tree.height == 50
      @default.tree.ants.big == false
      @default.tree.ants.fast == true
      @default.tree.ants.home.should be_nil
      lambda { @default.tree.ants.home.sq_feet }.should raise_error
    end

    context "Properties" do
      before do
        @default = SimpleConf {
          server "localhost"
          port 80, :override => false
          socket "/tmp/sock.sock"

          tree {
            leafs 30
            height 50
            bugs false, :override => false
            ants{
              big false, :override => false
              fast true
            }
          }
        }

      end
      it "should merge and inherit options" do
        @default.merge!(@new)
        @default.port 8080
        @default.port.should == 80
      end

      it "should merge and inherit nested properties" do
        @default.merge!(@new)
        @default.tree.bugs.should == false
        @default.tree.ants.big.should == false
        @default.tree.leafs 200
        @default.tree.leafs.should == 60
      end
    end

    context "merging with init_only" do
      before do
        @new = SimpleConf(:init_only => true) {
          port 90
          socket "haha"
          tree {
            leafs 60, :override => false
            bugs true
            ants {
              fast false
              home {
                big true
                sq_feet 5000
              }
            }
          }
        }

      end

      it "the newly merged item should be init_only" do
        @default.merge!(@new)
        @default.__init_only__.should == true
      end

      it "the newly merged item should act as init_only" do
        @default.merge!(@new)
        lambda{
          @default.name "name"
        }.should raise_error
      end
    end

  end
end
