# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test '#name_or_email' do
    user = User.new(email: 'test_user_foo@example.com', name: '', password: 'password')
    assert_equal 'test_user_foo@example.com', user.name_or_email

    user.name = 'user Foo'
    assert_equal 'user Foo', user.name_or_email
  end
end
