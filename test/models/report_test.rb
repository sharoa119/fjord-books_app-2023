# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  def setup
    @user1 = User.create!(name: 'user Foo', email: 'user_foo@example.com', password: 'password')
    @user2 = User.create!(name: 'user Bar', email: 'user_bar@example.com', password: 'password')
    @report = Report.create!(
      title: 'Sample Report',
      content: 'This is a sample report.',
      user: @user1
    )
  end

  test '#editable?' do
    assert @report.editable?(@user1)
    assert_not @report.editable?(@user2)
  end

  test '#created_on' do
    assert_equal @report.created_at.to_date, @report.created_on
  end

  test 'should not save report without title or content or user' do
    report = Report.new(title: 'Some title', user: @user1)
    assert_not report.save

    report = Report.new(content: 'Some content', user: @user1)
    assert_not report.save

    report = Report.new(title: 'Some title', content: 'Some content')
    assert_not report.save
  end

  test 'should not save report with empty title or content' do
    report = Report.new(title: '', content: 'Some content', user: @user1)
    assert_not report.save

    report = Report.new(title: 'Some title', content: '', user: @user1)
    assert_not report.save
  end

  test 'should belong to user' do
    assert_equal @user1, @report.user
  end
end
