$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'acts_as_gold'
ActiveRecord::Base.class_eval { include ActsAsGold }