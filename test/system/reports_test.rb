# frozen_string_literal: true

require 'application_system_test_case'

class ReportsTest < ApplicationSystemTestCase
  fixtures :users, :reports

  setup do
    @user = users(:user_foo)
    @report = reports(:sample_report)

    visit root_url
    fill_in 'Eメール', with: @user.email
    fill_in 'パスワード', with: 'password'
    click_button 'ログイン'
    assert_text 'ログインしました。'
  end

  test '日報を作成できること' do
    visit new_report_url
    fill_in 'タイトル', with: 'New Report'
    fill_in '内容', with: 'This is the content of the new report.'
    click_button '登録する'

    assert_text 'New Report'
    assert_text 'This is the content of the new report.'
  end

  test '日報を編集ができること' do
    visit edit_report_url(@report)
    fill_in 'タイトル', with: 'Updated Report Title'
    click_button '更新する'

    assert_text 'Updated Report Title'
  end

  test '日報を削除できること' do
    visit reports_url
    assert_text @report.title

    within '.index-item', text: @report.title do
      click_on 'この日報を表示'
    end

    assert_selector 'button', text: 'この日報を削除'
    click_button 'この日報を削除'

    assert_current_path reports_url
    assert_no_text @report.title
  end
end
