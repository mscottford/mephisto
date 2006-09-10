require File.dirname(__FILE__) + '/../test_helper'

context "Dispatcher" do
  fixtures :sites, :sections

  specify "should dispatch to home" do
    assert_dispatch :list, sections(:home), %w()
  end

  specify "should dispatch to home archives" do
    assert_dispatch :archives, sections(:home), 'archives', %w(archives)
  end

  specify "should dispatch to home monthly archives" do
    assert_dispatch :archives, sections(:home), 'archives', '2006', '9', %w(archives 2006 9)
  end

  specify "should error on invalid archive dispatch" do
    assert_dispatch :error, sections(:home), 'archives', 'foo', %w(archives foo)
    assert_dispatch :error, sections(:home), 'archives', '2006', 'foo', %w(archives 2006 foo)
    assert_dispatch :error, sections(:home), 'archives', '2006', '9', 'foo', %w(archives 2006 9 foo)
  end

  specify "should dispatch page sections" do
    assert_dispatch :page, sections(:about), %w(about)
    assert_dispatch :page, sections(:about), 'foo', %w(about foo)
  end

  specify "should not allow page name on blog sections" do 
    assert_dispatch :error, sections(:home), 'foo', %w(foo)
  end

  specify "should dispatch to tags" do
    assert_dispatch :tags, nil, %w(tags)
    assert_dispatch :tags, nil, 'a', %w(tags a)
    assert_dispatch :tags, nil, 'a', 'b', %w(tags a b)
  end

  specify "should dispatch to search" do
    assert_dispatch :search, nil, %w(search)
  end
  
  specify "should error on invalid search" do
    assert_dispatch :error, nil, %w(search foo)
  end

  specify "should dispatch to permalink" do
    options = {:year => '2006', :month => '9', :day => '1', :permalink => 'foo'}
    assert_dispatch :single, nil, options, %w(2006 9 1 foo)
  end

  specify "should recognize permalinks" do
    @site = sites(:first)
    
    options = {:year => '2006', :month => '9', :day => '1', :permalink => 'foo'}
    assert_equal options, Mephisto::Dispatcher.recognize_permalink(@site, %w(2006 9 1 foo))
    
    @site.permalink_slug = 'entries/:id/:permalink'
    @site.permalink_regex(true)
    options = {:id => '5', :permalink => 'foo-bar-baz'}
    assert_equal options, Mephisto::Dispatcher.recognize_permalink(@site, %w(entries 5 foo-bar-baz))
  end

  specify "should ignore unrecognized permalinks" do
    assert_nil Mephisto::Dispatcher.recognize_permalink(sites(:first), %w(entries 5 foo-bar-baz))
    assert_nil Mephisto::Dispatcher.recognize_permalink(sites(:first), %w(200 9 1 foo))
    assert_nil Mephisto::Dispatcher.recognize_permalink(sites(:first), %w(2006 239 1 foo))
    assert_nil Mephisto::Dispatcher.recognize_permalink(sites(:first), %w(2006 9 123 foo))
    assert_nil Mephisto::Dispatcher.recognize_permalink(sites(:first), %w(2006 9 1 a_b))
  end

  protected
    def assert_dispatch(dispatch_type, section, *args)
      path   = args.pop
      result = Mephisto::Dispatcher.run sites(:first), path
      assert_equal [dispatch_type, section, *args], result
    end
end