require 'fj-r'
require 'pp'

describe FjR do
  it "temp" do
    pp FjR::Parser.new.parse("
      class T extends Object {
        T() { super(); }
        Object foo(Object x) {
          return x;
        }
      }
      new T().foo(new Object())
    ")
  end
end
