# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @user1 = users(:user_foo)
    @user2 = users(:user_bar)

    @fixed_time = Time.zone.local(2024, 9, 4)
    travel_to @fixed_time do
      @report = Report.create!(
        title: 'Sample Report',
        content: 'This is a sample report.',
        user: @user1
      )
    end
  end

  test '#editable?' do
    assert @report.editable?(@user1)
    assert_not @report.editable?(@user2)
  end

  test '#created_on' do
    assert_equal '2024-09-04', @report.created_on.to_s
  end

  test 'should belong to user' do
    assert_equal @user1, @report.user
  end
end
