require 'test/unit'

require 'rubygems'
gem 'activerecord', '>= 1.15.4.7794'
require 'active_record'

require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :players do |t|
      t.column :money, :integer
    end
    
    create_table :another_players do |t|
      t.column :pennies, :integer
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Player < ActiveRecord::Base
  acts_as_gold # defaults to :column => :money
end

class AnotherPlayer < ActiveRecord::Base
  acts_as_gold :column => :pennies
end

class ActsAsGoldTest < Test::Unit::TestCase
  
  def setup
    # Creates a Player iwth 250G, 44S and 55C
    setup_db
    Player.create(:money => 2504455)
    @player = Player.find(:first)
  end
  
  def teardown
    teardown_db
  end
  
  def test_alternate_column_name
    AnotherPlayer.create(:pennies => 1005095)
    @alt_player = AnotherPlayer.find(:first)
    
    assert_equal 1005095, @alt_player.pennies
    assert_equal 100, @alt_player.gold
    assert_equal 50, @alt_player.silver
    assert_equal 95, @alt_player.copper
  end
  
  def test_money_retrieval
    assert_equal 2504455, @player.money
    
    assert_equal 250, @player.gold
    assert_equal 44, @player.silver
    assert_equal 55, @player.copper
  end
  
  def test_numeric_extensions
    assert_equal 2500000, 250.gold
    assert_equal 2500, 25.silver
    assert_equal 25, 25.copper
  end
  
  def test_money_earning
    assert_equal 2504455, @player.money
    assert @player.earn(3.gold + 22.silver + 33.copper)
    assert_equal 2536688, @player.money
  end
  
  def test_money_spending
    assert_equal 2504455, @player.money
    assert @player.spend(3.gold + 22.silver + 33.copper)
    assert_equal 2472222, @player.money
  end
  
  def test_too_much_money_spending
    assert_equal 2504455, @player.money
    assert_raise(ActsAsGold::NotEnoughMoneyError) { @player.spend(300.gold) }
    assert_equal 2504455, @player.money
  end
end
