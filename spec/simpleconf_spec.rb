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

  context "init_only" do
    it "should throw an error if we use strict option and we have never encountered that config item" do
      c = SimpleConf.build :init_only => true do
        host "localhost"
      end
      lambda {
        c.port
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
end
