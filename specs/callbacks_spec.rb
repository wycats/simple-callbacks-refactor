require File.join(File.dirname(__FILE__), "..", "lib", "callbacks")

class MyKlass
  include Callbacks
  
  define_callback :save
  save_callback :meth
  save_callback {|k| k.history << "proc"}
  
  attr_accessor :history
  def initialize
    @history = []
  end
  
  def meth
    @history << "meth"
  end
  
  def save
    run_callbacks(:save)
  end
end

describe Callbacks do
  it "should run the callbacks on save" do
    obj = MyKlass.new
    obj.save
    obj.history.should == ["meth", "proc"]
  end
end

require "rbench"

RBench.run(100_000) do
  report("callbacks") do
    obj = MyKlass.new
    obj.save
  end
end