require 'spec_helper'

describe Search do
  it "searches based on no collection" do
    site = Site.make

    search = Search.new []
    search.results.should eq({})
  end

  it "searches based on collection id found" do
    site = Site.make

    search = Search.new site.collection_id
    search.results[:sites].should eq([{:id => site.id, :lat => site.lat.to_f, :lng => site.lng.to_f}])
  end

  it "searches with excluded id" do
    site = Site.make

    search = Search.new site.collection_id
    search.exclude_id site.id
    search.results[:sites].should be_nil
  end

  it "searches based on many collection ids found" do
    site1 = Site.make :lat => 45, :lng => 90
    site2 = Site.make :lat => -45, :lng => -90

    search = Search.new [site1.collection_id, site2.collection_id]
    search.results[:sites].length.should eq(2)
  end

  it "searches based on collection id and bounds found" do
    site = Site.make :lat => 10, :lng => 20

    search = Search.new site.collection_id
    search.bounds = {:s => 9, :n => 11, :w => 19, :e => 21}
    search.results[:sites].length.should eq(1)
  end

  it "searches based on collection id and bounds not found" do
    site = Site.make :lat => 10, :lng => 20

    search = Search.new site.collection_id
    search.bounds = {:s => 11, :n => 12, :w => 21, :e => 22}
    search.results[:sites].should be_nil
  end

  context "hierarchy" do
    let(:collection) { Collection.make }

    before(:each) do
      @site1 = collection.sites.make :group => true
      @site2 = collection.sites.make :group => true, :parent_id => @site1.id
      @site21 = collection.sites.make :parent_id => @site2.id, :lat => 30, :lng => 40
      @site21 = collection.sites.make :parent_id => @site2.id, :lat => 40, :lng => 60
      @site3 = collection.sites.make :group => true, :parent_id => @site1.id, :lat => 1, :lng => 2, :location_mode => :manual
      @site31 = collection.sites.make :parent_id => @site3.id, :lat => 10, :lng => 20
      @site32 = collection.sites.make :parent_id => @site3.id, :lat => 15, :lng => 20
    end

    it "searches with group hierarchy" do
      search = Search.new collection.id
      search.zoom = 3
      search.bounds = {:s => 8, :n => 18, :e => 22, :w => 18}
      results = search.results
      results[:sites].should be_nil
      results[:clusters].should eq([{:id => "g#{@site3.id}", :lat => 1.0, :lng => 2.0, :count => 2, :max_zoom => 4}])
    end

    it "searches with group hierarchy with bounds crossing the anti-meridian" do
      search = Search.new collection.id
      search.zoom = 3
      search.bounds = {:s => 8, :n => 18, :e => 25, :w => 120}
      results = search.results
      results[:sites].should be_nil
      results[:clusters].should eq([{:id => "g#{@site3.id}", :lat => 1.0, :lng => 2.0, :count => 2, :max_zoom => 4}])
    end
  end
end
