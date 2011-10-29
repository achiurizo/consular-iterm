require File.expand_path('../spec_helper', __FILE__)

describe Consular::ITermDSL do

  before do
    @dsl = Consular::DSL.new File.expand_path('../fixtures/bar.term', __FILE__)
  end

  it "includes itself into Consular::DSL" do
    assert_includes Consular::DSL.included_modules, Consular::ITermDSL
  end

  describe ".to_hash" do
    before do
      @result = @dsl.to_hash
    end

    it "returns the default window pane" do
      assert_equal ['top'], @result[:windows]['default'][:panes]['pane0'][:commands]
    end

    it "returns the first window first panes" do
      @window1 = @result[:windows]['window1']

      assert @window1[:panes]['pane0'][:is_top_pane], "that this is marked as top most pane"
      assert_equal ['ls'],     @window1[:panes]['pane0'][:commands]
      assert_equal ['uptime'], @window1[:panes]['pane0'][:panes]['pane0'][:commands]
    end

    it "returns the first window's second pane" do
      @window1 = @result[:windows]['window1']
      assert_equal ['ps'],    @window1[:panes]['pane1'][:commands]
      assert_equal ['test'],  @window1[:panes]['pane2'][:commands]
    end

    it "still returns tabs correctly" do
      @window1 = @result[:windows]['window1']

      assert_equal ['echo'],    @window1[:tabs]['tab1'][:commands]
      assert_equal ['default'], @window1[:tabs]['default'][:commands]
    end

    it "still returns multiple windows" do
      @window2 = @result[:windows]['window2']

      assert @window2[:panes]['pane1'][:is_top_pane], "that this is marked as top most pane"

      assert_equal ['second window'], @window2[:panes]['pane0'][:commands]
      assert_equal ['second pane'],   @window2[:panes]['pane1'][:commands]
      assert_equal ['third pane'],    @window2[:panes]['pane1'][:panes]['pane0'][:commands]

      assert_equal ['tab1'], @window2[:tabs]['default'][:commands]
      assert_equal ['tab2'], @window2[:tabs]['tab1'][:commands]
    end

  end

end
