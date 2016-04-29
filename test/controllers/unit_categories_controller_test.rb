require 'test_helper'

class UnitCategoriesControllerTest < ActionController::TestCase
  setup do
    @unit_category = unit_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:unit_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create unit_category" do
    assert_difference('UnitCategory.count') do
      post :create, unit_category: {  }
    end

    assert_redirected_to unit_category_path(assigns(:unit_category))
  end

  test "should show unit_category" do
    get :show, id: @unit_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @unit_category
    assert_response :success
  end

  test "should update unit_category" do
    patch :update, id: @unit_category, unit_category: {  }
    assert_redirected_to unit_category_path(assigns(:unit_category))
  end

  test "should destroy unit_category" do
    assert_difference('UnitCategory.count', -1) do
      delete :destroy, id: @unit_category
    end

    assert_redirected_to unit_categories_path
  end
end
