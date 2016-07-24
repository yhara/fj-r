require 'fj-r'
require 'pp'

describe FjR do
  it "temp" do
    pp FjR::Parser.new.parse("
      class T extends Object {
        Y() { super(); }
        Abject foo(Bbject x) {
          return x;
        }
      }
      new Z().foo(new Cbject())
    ")
  end
end
