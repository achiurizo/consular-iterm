require File.expand_path('../spec_helper', __FILE__)

describe Consular::ITerm do
  before do
    @core = Consular::ITerm.new File.expand_path('../fixtures/bar.term', __FILE__)
  end

  it "should return name of core with #to_s" do
    assert_equal "Consular::ITerm Mac OSX iTerm2", Consular::ITerm.to_s
  end

  it "should add itself to Consular cores" do
    assert_includes Consular.cores, Consular::ITerm
  end

  it "should set ivars on .initialize" do
    refute_nil @core.instance_variable_get(:@termfile)
    refute_nil @core.instance_variable_get(:@terminal)
  end

  it "should prepend commands with .prepend_befores" do
    assert_equal ['ps', 'ls'], @core.prepend_befores(['ls'], ['ps'])
    assert_equal ['ls'],       @core.prepend_befores(['ls'])
  end

  it "should set the title of the tab if one given" do
    (name = Object.new).expects(:set)
    (tab = Object.new).stubs(:name).returns(name)
    @core.set_title('the title', tab)
  end

  it "should not bother setting the tab title if not one given" do
    (name = Object.new).expects(:set).never
    (tab = Object.new).stubs(:name).returns(name)
    @core.set_title(nil, tab)
  end

end
