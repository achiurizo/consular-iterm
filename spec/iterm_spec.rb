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

  it "should set .set_title" do
    assert_equal ["PS1=\"$PS1\\[\\e]2;hey\\a\\]\"",'ls'], @core.set_title('hey', ['ls'])
    assert_equal ['ls'],                                  @core.set_title(nil,   ['ls'])
  end

end
