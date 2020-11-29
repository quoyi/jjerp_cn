require 'test_helper'

class StaticControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get root_url
    assert_response :success
  end

  # test 'should get about' do
  #   get about_url
  #   assert_response :success
  # end

  # test 'should get contact' do
  #   get contact_url
  #   assert_response :success
  # end

  test 'should get terms' do
    get terms_url
    assert_response :success
  end

  test 'should get privacy' do
    get privacy_url
    assert_response :success
  end

  test 'should get expired' do
    get expired_url
    assert_response :success
  end

  # test 'should get home' do
  #   get home_url
  #   assert_redirected_to new_user_session_url
  # end
end
