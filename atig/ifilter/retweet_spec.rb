#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/ifilter/retweet'
require 'atig/twitter_struct'
require 'atig/spec_helper'

describe Atig::IFilter::Retweet do
  def filtered(text, opt={})
    Atig::IFilter::Retweet.call status(text, opt)
  end

  before do
    @rt = Atig::IFilter::Retweet::Prefix
  end

  it "should throw normal status" do
    filtered("hello").should be_text("hello")
  end

  it "should prefix RT for Retweet" do
    filtered("RT: hello...",
             'retweeted_status'=>{ 'text' => 'hello',
               'user' => {
                 'screen_name' => 'mzp'
               } }).
      should be_text("#{@rt}RT @mzp: hello")
  end
end
