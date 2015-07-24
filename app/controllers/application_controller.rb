#may not need these
require 'twitter'
require 'twitter.rb'
require 'open-uri'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  #before_filter :search                #works when commented out
  
  
  def results
    # puts params[:search_field].inspect
    @tweets = $twitter.search(params[:search_field]).take(100)    #takes [:search_field] from search.html.erb through get 'search' => 'application#search'
                                                                  #then sends it to search.html.erb by post 'results' => 'application#results'
    @hashTags = Hash.new
    @userMention= Hash.new #hashes for usermention and hashtag counting
    
    @tweets.each do |tweet|
      tweet.hashtags.each do |tag|
        
        #@hashTags[tag.id] += 1; #I use the id of the hashtag which I know exist here.  This ID is for sure uniq making it more secure to count.
        
        
        #@twitter |tweet| -> tweet.hashtags |tags| -> tag.attrs[:text] == the text of the twitter hashtag
        #hashtag = tag.attrs[:text]
        if(!@hashTags.key?(tag.attrs[:text]))
          @hashTags[tag.attrs[:text]] = 0
        end
        @hashTags[tag.attrs[:text]] += 1

        #hashtag.each_line { |word| @hashTags[word] =+ 1 }#solution
        #@hashTags = Array.new(hashtag) {Hash.new}
      end
      
      #mention[:entities][:user_mentions][0][:screen_name]


      #-----------------find user mentions------------------#
      tweet.user_mentions.each do |mention|
        #Twitter |tweet| -> user_mentions |mention| -> mention.attrs[:screen_name]
        #userMention.each { |word| @userNames[word] += 1 }

        if(!@userMention.key?(mention.attrs[:screen_name]))
          @userMention[mention.attrs[:screen_name]]= 0
        end
        
        @userMention[mention.attrs[:screen_name]] += 1
      end
      #-----------------------------------------------------#      
      
    end
    
    
    #sorts in ascending (1, 3, 7, 23, 200) order, then reverses so results.html.erb will have them displayed starting with the most frequent @ & #
    @hashTags = @hashTags.sort_by{|key,value| value}.reverse
    @userMention = @userMention.sort_by{|key,value| value}.reverse
    
    puts "hashTags    hash: #{@hashTags}"
    puts "userMention hash: #{@userMention}"
  end
end