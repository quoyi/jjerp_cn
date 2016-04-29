require 'test_helper'

class PartCategoriesControllerTest < ActionController::TestCase
  setup do
    @part_category = part_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:part_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create part_category" do
    assert_difference('PartCategory.count') do
      post :create, part_category: {  }
    end

    assert_redirected_to part_category_path(assigns(:part_category))
  end

  test "should show part_category" do
    get :show, id: @part_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @part_category
    assert_response :success
  end

  test "should update part_category" do
    patch :update, id: @part_category, part_category: {  }
    assert_redirected_to part_category_path(assigns(:part_category))
  end

  test "should destroy part_category" do
    assert_difference('PartCategory.count', -1) do
      delete :destroy, id: @part_category
    end

    assert_redirected_to part_categories_path
  end
end
