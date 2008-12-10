spec_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))

require File.join(spec_dir, "spec_helper")

class Hash
  def indexes(*values)
    raise NotImplementedError, "Use Hash#select instead."
  end
  alias_method :indices, :indexes
end

describe Hash, :shared => true do
  it "should convert to a String" do
    @hash.to_s.should == @hash.to_hash.to_s
  end

  it "should be inspectable" do
    @hash.inspect.should == @hash.to_hash.inspect
  end

  it "should convert to a Hash" do
    @hash.to_hash.size.should == @hash.size
    @hash.to_hash.each do |key, value|
      @hash[key].should == value
    end
  end

  it "should clear correctly" do
    @hash.clear
    @hash.should be_empty
    @hash.size.should == 0
  end

  it "should have the same number of keys and values" do
    @hash.keys.size.should == @hash.values.size
  end

  it "should dup correctly" do
    @hash.should == @hash.dup
    @hash.object_id.should_not == @hash.dup.object_id
  end
end

describe Hash, "when non-empty", :shared => true do
  it_should_behave_like("Hash")

  it "should not be empty" do
    @hash.should_not be_empty
  end

  it "should have a size larger than zero" do
    @hash.size.should > 0
    @hash.keys.size.should > 0
    @hash.values.size.should > 0
  end

  it "should not be equal to the empty Hash" do
    @hash.should_not == {}
  end

  it "should check key inclusion correctly" do
    key = @hash.keys.first
    @hash.should be_include(key)
    @hash.should be_member(key)
    @hash.should have_key(key)
    @hash.should be_key(key)
  end

  it "should check value inclusion correctly" do
    value = @hash.values.first
    @hash.should have_value(value)
    @hash.should be_value(value)
  end

  it "should delete correctly" do
    key = @hash.keys.first
    value = @hash[key]
    original_size = @hash.size
    @hash.delete(key).should == value
    @hash.size.should == (original_size - 1)
    @hash.delete("Not-Here").should == @hash.default("Not-Here")
    (@hash.delete("Not-Here") do |key|
      "missing: #{key}"
    end).should == "missing: Not-Here"
    (@hash.delete(:'Not-Here') do |key|
      "missing: #{key}"
    end).should == "missing: Not-Here"
  end

  it "should shift correctly" do
    key = @hash.keys.first
    value = @hash[key]
    original_size = @hash.size
    @hash.shift.should == [key, value]
    @hash.size.should == (original_size - 1)
  end

  it "should fetch correctly" do
    key = @hash.keys.first
    value = @hash[key]
    @hash.fetch(key).should == value
    @hash.fetch(key, "missing").should == value
    @hash.fetch("Not-Here", "missing").should == "missing"
    (@hash.fetch("Not-Here") do |key|
      "missing: #{key}"
    end).should == "missing: Not-Here"
    (lambda do
      @hash.fetch("Not-Here")
    end).should raise_error(IndexError)
    @hash.fetch("Not-Here", nil).should == nil
    (lambda do
      @hash.fetch(1, 2, 3)
    end).should raise_error(ArgumentError)
  end

  it "should iterate correctly" do
    # Most of the specialized subclasses change the way keys work
    values = @hash.values
    @hash.each do |key, value|
      @hash.should be_include(key)
      values.should be_include(value)
    end
    @hash.each_pair do |key, value|
      @hash.should be_include(key)
      values.should be_include(value)
    end
    @hash.each_key do |key|
      @hash.should be_include(key)
    end
    @hash.each_value do |value|
      values.should be_include(value)
    end
  end
end

describe Hash, "when empty", :shared => true do
  it_should_behave_like("Hash")

  it "should be empty" do
    @hash.should be_empty
  end

  it "should have a size of zero" do
    @hash.size.should == 0
  end

  it "should not raise an error when iterating" do
    @hash.each
  end

  it "should be equal to the empty Hash" do
    @hash.should == {}
  end

  it "should index correctly" do
    @hash.key("Not-Here").should == nil
    @hash.key(99999).should == nil
  end
end
