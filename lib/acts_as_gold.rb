module ActsAsGold
  # Thrown when trying to spend more than you have.
  class NotEnoughMoneyError < StandardError
  end
  
  def self.included(base)
    base.extend(ClassMethods)
  end

  # This +acts_as+ extension provides the capabilities for splitting a given interger column into 
  # three separte coin values: Copper, Silver and Gold. 
  #
  # A simple example: a Charachter has money ( t.integer :money, :limit => 20)
  #
  #   class Character < ActiveRecord::Base
  #     acts_as_gold                      # Uses the money attributes
  #     acts_as_gold :column => :pennies  # Uses the pennies attributes
  #   end
  #
  #   character.money   = 57503
  #   character.gold    = 5
  #   character.silver  = 75
  #   character.copper  = 3
  #
  #   character.money  += 2.gold + 10.copper
  #   character.gold   = 7
  #   character.copper = 13
  #   character.money  = 77513
  #
  # Copper and Silver have a maximum of 99. E.g. 100 copper => 1 silver and 100 silver => 1 Gold. 
  # The maximum amount of money depends on the integer type used in the database:
  #
  # signed int(11)             2,147,483,647   =>  214,748 Gold, 36 Silver, 47 Copper
  # signed int(20) 9,223,372,036,854,775,807   =>  922,337,203,685,477 Gold, ++8 Silver, 07 Copper
  #
  module ClassMethods
    # Configuration options are:
    #
    # * +column+ - specifies the column name to use for keeping the money integer (default: +money+)
    def acts_as_gold(options = {})
      configuration = { :column => "money" }
      configuration.update(options) if options.is_a?(Hash)

      class_eval <<-EOV
        include ActsAsGold::InstanceMethods
        
        def money_column
          '#{configuration[:column]}'
        end

      EOV
    end
  end
  
  # Allow Fixnum and Bignum to easily convert to Gold, Silver or Copper. 
  # This allows for things like:
  #
  # character.money = 2.gold + 45.silver + 50.copper
  module IntegerExtensions
    # 1.gold => 10000
    def gold
      self * 10000
    end
    
    # 1.silver => 100
    def silver
      self * 100
    end
    
    # Dummy, 1.copper => !
    def copper
      self
    end
  end

  # All the methods available to records that have the acts_as_gold method enabled.
  module InstanceMethods
    # Earn money. 
    #
    # Either enter a total money value, or sum it up with gold and def silver. To earn
    # 1 Gold, 95 silver and 0 copper you can do the following:
    #
    # character.earn(19500)
    # character.earn(1.gold + 95.silver)
    #
    # This return true if the amount was added successfully
    def earn(amount)
      update_attribute(:money, money + amount)
    end
    
    # Spend money
    #
    # You can specify money the same way as with earning money.
    #
    # We return true if the money was spend successfully.
    #
    # This will raise a 'ActiveRecord::Acts::Gold::NotEnoughMoneyError' when there's not enough money
    def spend(amount)
      if money >= amount
        update_attribute(:money, money - amount)
      else
        raise ActsAsGold::NotEnoughMoneyError
      end
    end
    
    # Return the amount of Gold
    def gold
      split_copper.first.divmod(100).first
    end

    def silver
      split_copper.first.divmod(100).last
    end
    
    def copper
      split_copper.last
    end

    private
    
    def split_copper
      self.send(money_column).divmod(100)
    end
  end 
end

class Fixnum
  include ActsAsGold::IntegerExtensions
end

class Bignum
  include ActsAsGold::IntegerExtensions
end

ActiveRecord::Base.class_eval { include ActsAsGold }