require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "#name_or_email" do
    user = User.new(email: 'test_user_foo@example.com', name: '', password: 'password')
    assert_equal 'test_user_foo@example.com', user.name_or_email

    user.name = 'user Foo'
    assert_equal 'user Foo', user.name_or_email
  end

  test "should not save user without email" do
    user = User.new(name: 'user Foo', password: 'password')
    assert_not user.save
  end

  test "should not save user without password" do
    user = User.new(name: 'user Foo', email: 'test_user_foo@example.com')
    assert_not user.save
  end

  test "should not save user with duplicate email" do
    user1 = User.create(name: 'User Foo', email: 'test_user_foo@example.com', password: 'password')
    user2 = User.new(name: 'User Bar', email: 'test_user_foo@example.com', password: 'password')
    assert_not user2.save
  end
end
