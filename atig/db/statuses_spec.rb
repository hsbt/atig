#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/statuses'

describe Atig::Db::Statuses do
  def status(id, text)
    status = stub('Status')
    status.stub!(:id  ).and_return(id)
    status.stub!(:text).and_return(text)
    status
  end

  def user(name)
    user = stub('User')
    user.stub!(:screen_name).and_return(name)
    user
  end

  before do
    @listened = []
    @db = Atig::Db::Statuses.new 4

    @a = status 1, 'a'
    @b = status 2, 'b'
    @c = status 3, 'c'
    @d = status 4, 'd'

    @alice = user 'alice'
    @bob = user 'bob'

    @db.add :status => @a , :user => @alice
    @db.add :status => @b , :user => @bob
    @db.add :status => @c , :user => @alice
  end

  it "should call listeners" do
    status = tid = user = nil
    @db.listen{|x| status,tid,user = *x }

    @db.add :status => @d, :user => @alice

    stauts.should == @d
    tid.should match(/\w+/)
    user.should @alice
  end

  it "should have only 4 statuses" do
    @db.add :status => @d, :user => @alice
    @db.size.should == 4

    @db.add :status => status(42,'new'), :user => @alice
    @db.size.should == 4
  end

  it "should not contain duplicate" do
    called = false
    @db.listen{|*_| called = true }

    @db.add :status => @c, :user => @bob
    called.should be_false
  end

  it "should be found by id" do
    entry = @db.find_by_id 1
    entry.status.should == @a
    entry.user  .should == @alice
    entry.tid   .should match(/\w+/)
  end

  it "should be found by tid" do
    entry = @db.find_by_id(1)
    @db.find_by_tid(entry.tid).should entry
  end

  it "should be found by user" do
    a,b = *@db.find_by_user(@alice)

    a.status.should == @a
    a.user  .should == @alice
    a.tid   .should == match(/\w+/)

    b.status.should == @c
    b.user.should   == @alice
    b.tid.should    == match(/\w+/)
  end

  it "should be found by screen_name" do
    a,b = *@db.find_by_screen_name('alice')

    a.status.should == @a
    a.user  .should == @alice
    a.tid   .should == match(/\w+/)

    b.status.should == @c
    b.user.should   == @alice
    b.tid.should    == match(/\w+/)
  end
end