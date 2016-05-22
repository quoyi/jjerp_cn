require 'test_helper'

class ExpendsControllerTest < ActionController::TestCase
  setup do
    @expend = expends(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:expends)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create expend" do
    assert_difference('Expend.count') do
      post :create, expend: { string: @expend.string }
    end

    assert_redirected_to expend_path(assigns(:expend))
  end

  test "should show expend" do
    get :show, id: @expend
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @expend
    assert_response :success
  end

  test "should update expend" do
    patch :update, id: @expend, expend: { string: @expend.string }
    assert_redirected_to expend_path(assigns(:expend))
  end

  test "should destroy expend" do
    assert_difference('Expend.count', -1) do
      delete :destroy, id: @expend
    end

    assert_redirected_to expends_path
  end
end
