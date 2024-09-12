# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  fixtures :users, :reports

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

# 追加するテスト
  test 'should create mentions after save' do
    # メンションのあるコンテンツを設定
    mentioned_report = reports(:another_report) # 適切なフィクスチャを使用
    @report.content = "Mentioning http://localhost:3000/reports/#{mentioned_report.id}"

    # 保存してメンションが作成されるか確認
    assert_difference('@report.mentioning_reports.count', 1) do
      @report.save
    end

    # 期待するメンションが含まれているか確認
    assert_includes @report.mentioning_reports, mentioned_report
  end

  test 'should handle mentions that reference non-existent reports' do
    @report.content = "Mentioning http://localhost:3000/reports/999999"
    @report.save

    assert_empty @report.mentioning_reports
  end

  test 'should create multiple mentions' do
    mentioned_report1 = reports(:another_report)
    mentioned_report2 = reports(:yet_another_report)
    @report.content = "Mentioning http://localhost:3000/reports/#{mentioned_report1.id} and http://localhost:3000/reports/#{mentioned_report2.id}"
    @report.save

    assert_includes @report.mentioning_reports, mentioned_report1
    assert_includes @report.mentioning_reports, mentioned_report2
  end
end
