spec_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))

require File.join(spec_dir, "spec_helper")

require "hashbag/case_insensitive_hash"

describe HashBag::CaseInsensitiveHash,
    "when given a set of HTTP headers", :shared => true do
  it "should include the right headers" do
    @hash.should be_include("Content-Type")
    @hash.should be_include("CoNtEnT-TyPe")
    @hash.should be_include("content-type")
    @hash.should be_include("X-XRDS-Location")
    @hash.should be_include("X-XRDS-LOCATION")
    @hash.should be_include("ETag")
    @hash.should be_include("Etag")
  end

  it "should allow comparisons to normal Hashes" do
    @hash.should == {
      "Content-Type" => "text/html; charset=UTF-8",
      "X-XRDS-Location" => "http://example.com/xrds/",
      "ETag" => "3da541559918a808c2402bba5012f6c60b27661c"
    }
    @hash.should == {
      "content-type" => "text/html; charset=UTF-8",
      "x-xrds-location" => "http://example.com/xrds/",
      "etag" => "3da541559918a808c2402bba5012f6c60b27661c"
    }
  end

  it "should assign values correctly" do
    @hash["content-type"] = "first"
    @hash["CONTENT-TYPE"] = "second"
    @hash["Content-Type"] = "third"
    @hash.to_hash.should == {
      "Content-Type" => "third",
      "X-XRDS-Location" => "http://example.com/xrds/",
      "ETag" => "3da541559918a808c2402bba5012f6c60b27661c"
    }
  end

  it "should merge correctly" do
    merged_hash = @hash.merge({
      "X-Originating-IP" => "127.0.0.1",
      "Content-Type" => "application/xml; charset=UTF-8"
    })
    merged_hash.should == {
      "Content-Type" => "application/xml; charset=UTF-8",
      "X-XRDS-Location" => "http://example.com/xrds/",
      "ETag" => "3da541559918a808c2402bba5012f6c60b27661c",
      "X-Originating-IP" => "127.0.0.1"
    }
    merged_hash.should be_include("content-type")
    merged_hash.should be_include("x-xrds-location")
    merged_hash.should be_include("etag")
    merged_hash.should be_include("x-originating-ip")
    merged_hash = @hash.merge({
      "X-Originating-IP" => "127.0.0.1",
      "Content-Type" => "application/xml; charset=UTF-8"
    }) do |key, old_value, new_value|
      key.should == "Content-Type"
      old_value.should == "text/html; charset=UTF-8"
      new_value.should == "application/xml; charset=UTF-8"
      "conflict"
    end
    merged_hash.should == {
      "Content-Type" => "conflict",
      "X-XRDS-Location" => "http://example.com/xrds/",
      "ETag" => "3da541559918a808c2402bba5012f6c60b27661c",
      "X-Originating-IP" => "127.0.0.1"
    }
    @hash.merge!({
      "X-Originating-IP" => "127.0.0.1",
      "Content-Type" => "application/xml; charset=UTF-8"
    }) do |key, old_value, new_value|
      "conflict"
    end
    @hash.should == {
      "Content-Type" => "conflict",
      "X-XRDS-Location" => "http://example.com/xrds/",
      "ETag" => "3da541559918a808c2402bba5012f6c60b27661c",
      "X-Originating-IP" => "127.0.0.1"
    }
  end

  it "should update correctly" do
    @hash.update({
      "X-Originating-IP" => "127.0.0.1"
    })
    @hash.should == {
      "Content-Type" => "text/html; charset=UTF-8",
      "X-XRDS-Location" => "http://example.com/xrds/",
      "ETag" => "3da541559918a808c2402bba5012f6c60b27661c",
      "X-Originating-IP" => "127.0.0.1"
    }
    @hash.should be_include("content-type")
    @hash.should be_include("x-xrds-location")
    @hash.should be_include("etag")
    @hash.should be_include("x-originating-ip")
    @hash.update({
      "Content-Type" => "application/xml; charset=UTF-8"
    }) do |key, old_value, new_value|
      key.should == "Content-Type"
      old_value.should == "text/html; charset=UTF-8"
      new_value.should == "application/xml; charset=UTF-8"
      "conflict"
    end
    @hash.should == {
      "Content-Type" => "conflict",
      "X-XRDS-Location" => "http://example.com/xrds/",
      "ETag" => "3da541559918a808c2402bba5012f6c60b27661c",
      "X-Originating-IP" => "127.0.0.1"
    }
  end

  it "should clear correctly" do
    @hash.clear
    @hash.should be_empty
  end

  it "should index correctly" do
    @hash.key("text/html; charset=UTF-8").should ==
      "Content-Type"
    @hash.key("http://example.com/xrds/").should ==
      "X-XRDS-Location"
    @hash.key("3da541559918a808c2402bba5012f6c60b27661c").should ==
      "ETag"
  end

  it "should raise an error for HashBag::CaseInsensitiveHash#indexes" do
    (lambda do
      @hash.indexes("http://example.com/xrds/", "text/html; charset=UTF-8")
    end).should raise_error
  end

  it "should look up values correctly" do
    @hash.values_at("X-XRDS-Location", "Content-Type").should == [
      "http://example.com/xrds/", "text/html; charset=UTF-8"
    ]
    @hash.values_at("content-type", "x-xrds-location").should == [
      "text/html; charset=UTF-8", "http://example.com/xrds/"
    ]
  end

  it "should delete correctly" do
    duplicated_hash = @hash.dup
    duplicated_hash.delete("Content-Type").should ==
      "text/html; charset=UTF-8"
    duplicated_hash.size.should == 2
    duplicated_hash = @hash.dup
    duplicated_hash.delete("content-type").should ==
      "text/html; charset=UTF-8"
    duplicated_hash.size.should == 2
    duplicated_hash = @hash.dup
    duplicated_hash.delete("Not-Here").should ==
      duplicated_hash.default("Not-Here")
    duplicated_hash.size.should == 3
    duplicated_hash = @hash.dup
    (duplicated_hash.delete("NOT-HERE") do |key|
      "missing: #{key}"
    end).should == "missing: NOT-HERE"
    duplicated_hash.size.should == 3
  end

  it "should conditionally delete correctly" do
    duplicated_hash = @hash.dup
    (duplicated_hash.delete_if do |key, value|
      value.size > 25
    end).should == {
      "X-XRDS-Location" => "http://example.com/xrds/",
      "Content-Type" => "text/html; charset=UTF-8"
    }
    duplicated_hash.size.should == 2
    duplicated_hash = @hash.dup
    (duplicated_hash.delete_if do |key, value|
      value.size > 25
    end).class.should == HashBag::CaseInsensitiveHash
  end

  it "should reject correctly" do
    (@hash.reject do |key, value|
      value.size > 25
    end).should == {
      "X-XRDS-Location" => "http://example.com/xrds/",
      "Content-Type" => "text/html; charset=UTF-8"
    }
    (@hash.reject do |key, value|
      value.size > 25
    end).class.should == HashBag::CaseInsensitiveHash
  end

  it "should destructively reject correctly" do
    duplicated_hash = @hash.dup
    (duplicated_hash.reject! do |key, value|
      value.size > 25
    end).should == {
      "X-XRDS-Location" => "http://example.com/xrds/",
      "Content-Type" => "text/html; charset=UTF-8"
    }
    duplicated_hash.size.should == 2
    duplicated_hash = @hash.dup
    (duplicated_hash.reject! do |key, value|
      value.size > 25
    end).class.should == HashBag::CaseInsensitiveHash
    (duplicated_hash.reject! do |key, value|
      value.size > 9999
    end).should == nil
  end

  it "should select correctly" do
    (@hash.select do |key, value|
      value.size > 25
    end).to_a.sort.should == [
      ["ETag", "3da541559918a808c2402bba5012f6c60b27661c"]
    ]
    (@hash.select do |key, value|
      value.size < 25
    end).to_a.sort.should == [
      ["Content-Type", "text/html; charset=UTF-8"],
      ["X-XRDS-Location", "http://example.com/xrds/"]
    ]
    (@hash.select do |key, value|
      false
    end).to_a.should == []
  end

  it "should sort correctly" do
    @hash.sort.should == [
      ["Content-Type", "text/html; charset=UTF-8"],
      ["ETag", "3da541559918a808c2402bba5012f6c60b27661c"],
      ["X-XRDS-Location", "http://example.com/xrds/"]
    ]
  end

  it "should fetch correctly" do
    @hash.fetch("Content-Type").should == "text/html; charset=UTF-8"
    @hash.fetch("content-type").should == "text/html; charset=UTF-8"
    @hash.fetch("Not-Here", "missing").should == "missing"
    (@hash.fetch("Not-Here") do |key|
      "missing: #{key}"
    end).should == "missing: Not-Here"
  end

  it "should iterate correctly" do
    (@hash.each do |key, value|
      [
        "Content-Type",
        "X-XRDS-Location",
        "ETag"
      ].should be_include(key)
      [
        "text/html; charset=UTF-8",
        "http://example.com/xrds/",
        "3da541559918a808c2402bba5012f6c60b27661c"
      ].should be_include(value)
    end).should == {
      "Content-Type" => "text/html; charset=UTF-8",
      "X-XRDS-Location" => "http://example.com/xrds/",
      "ETag" => "3da541559918a808c2402bba5012f6c60b27661c"
    }
  end

  it "should replace correctly" do
    @hash.replace({
      "X-Originating-IP" => "127.0.0.1"
    }).should == {
      "X-Originating-IP" => "127.0.0.1"
    }
    @hash.replace({
      "X-Originating-IP" => "127.0.0.1"
    }).class.should == HashBag::CaseInsensitiveHash
    @hash.size.should == 1
    (lambda do
      @hash.replace({:bogus => "bogus"})
    end).should raise_error(TypeError)
  end

  it "should invert correctly" do
    @hash.invert.should == {
      "text/html; charset=UTF-8" => "Content-Type",
      "http://example.com/xrds/" => "X-XRDS-Location",
      "3da541559918a808c2402bba5012f6c60b27661c" => "ETag"
    }
  end
end

describe HashBag::CaseInsensitiveHash, "when given non-String key values" do
  before do
    @hash = HashBag::CaseInsensitiveHash.new
  end

  it "should raise a TypeError during value writing" do
    (lambda do
      @hash[:bogus] = "bogus"
    end).should raise_error(TypeError)
  end

  it "should not raise an error during value reading" do
    @hash[:bogus].should == nil
  end

  it "should not raise an error while checking for value inclusion" do
    @hash.should_not be_include(:bogus)
  end

  it "should not raise an error during comparison" do
    @hash.should_not == {:bogus => "bogus"}
  end
end

describe HashBag::CaseInsensitiveHash,
    "when created by normal initialization" do
  before do
    @hash = HashBag::CaseInsensitiveHash.new
    @hash["Content-Type"] = "text/html; charset=UTF-8"
    @hash["X-XRDS-Location"] = "http://example.com/xrds/"
    @hash["ETag"] = "3da541559918a808c2402bba5012f6c60b27661c"
  end

  it_should_behave_like(
    "Hash when non-empty"
  )
  it_should_behave_like(
    "HashBag::CaseInsensitiveHash when given a set of HTTP headers"
  )
end

describe HashBag::CaseInsensitiveHash,
    "when created by Array initialization" do
  before do
    @hash = HashBag::CaseInsensitiveHash[
      *({
        "Content-Type"=>"text/html; charset=UTF-8",
        "X-XRDS-Location"=>"http://example.com/xrds/",
        "ETag"=>"3da541559918a808c2402bba5012f6c60b27661c"
      }.to_a.flatten)
    ]
  end

  it_should_behave_like(
    "Hash when non-empty"
  )
  it_should_behave_like(
    "HashBag::CaseInsensitiveHash when given a set of HTTP headers"
  )
end

describe HashBag::CaseInsensitiveHash,
    "when created by bogus Array initialization" do
  it "should raise an ArgumentError" do
    (lambda do
      @hash = HashBag::CaseInsensitiveHash["one", "two", "three"]
    end).should raise_error(ArgumentError)
  end
end

describe HashBag::CaseInsensitiveHash,
    "when created with a block" do
  before do
    @hash = HashBag::CaseInsensitiveHash.new do |hash, key|
      "missing: #{key}"
    end
    @hash["Content-Type"] = "text/html; charset=UTF-8"
    @hash["X-XRDS-Location"] = "http://example.com/xrds/"
    @hash["ETag"] = "3da541559918a808c2402bba5012f6c60b27661c"
  end

  it_should_behave_like(
    "Hash when non-empty"
  )
  it_should_behave_like(
    "HashBag::CaseInsensitiveHash when given a set of HTTP headers"
  )

  it "should correctly use the supplied block" do
    @hash["Not-Here"].should == "missing: Not-Here"
    @hash["not-here"].should == "missing: not-here"
    @hash[123].should == "missing: 123"
  end
end

describe HashBag::CaseInsensitiveHash,
    "when created with a fixed default value" do
  before do
    @hash = HashBag::CaseInsensitiveHash.new("missing")
    @hash["Content-Type"] = "text/html; charset=UTF-8"
    @hash["X-XRDS-Location"] = "http://example.com/xrds/"
    @hash["ETag"] = "3da541559918a808c2402bba5012f6c60b27661c"
  end

  it_should_behave_like(
    "Hash when non-empty"
  )
  it_should_behave_like(
    "HashBag::CaseInsensitiveHash when given a set of HTTP headers"
  )

  it "should correctly use the supplied block" do
    @hash["Not-Here"].should == "missing"
    @hash["not-here"].should == "missing"
    @hash[123].should == "missing"
  end
end

describe HashBag::CaseInsensitiveHash, "when empty" do
  before do
    @hash = HashBag::CaseInsensitiveHash.new
  end

  it_should_behave_like(
    "Hash when empty"
  )
end
