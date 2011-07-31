require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "validates user name" do
    assert !User.new(:name=>"@$%$#^$#").save
    assert !User.new(:name=>"thisnameistoolong").save
    assert !User.new(:name=>"spaces bad").save
    assert !User.new(:name=>"").save
  end

  test "create and get user" do
    user1 = User.new(:name=>"bob")
    assert user1.save
    assert User.find(user1)
  end

  test "cannot re-use name" do
    bob1 = User.new(:name=>"bob")
    assert bob1.save
    bob2 = User.new(:name=>"bob")
    assert !bob2.save, "saved 2 bobs"
  end
end
