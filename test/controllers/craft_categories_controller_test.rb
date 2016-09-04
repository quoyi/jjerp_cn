require 'test_helper'

class CraftCategoriesControllerTest < ActionController::TestCase
  setup do
    @craft_category = craft_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:craft_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create craft_category" do
    assert_difference('CraftCategory.count') do
      post :create, craft_category: { deleted: @craft_category.deleted, full_name: @craft_category.full_name, note: @craft_category.note, price: @craft_category.price, uom: @craft_category.uom }
    end

    assert_redirected_to craft_category_path(assigns(:craft_category))
  end

  test "should show craft_category" do
    get :show, id: @craft_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @craft_category
    assert_response :success
  end

  test "should update craft_category" do
    patch :update, id: @craft_category, craft_category: { deleted: @craft_category.deleted, full_name: @craft_category.full_name, note: @craft_category.note, price: @craft_category.price, uom: @craft_category.uom }
    assert_redirected_to craft_category_path(assigns(:craft_category))
  end

  test "should destroy craft_category" do
    assert_difference('CraftCategory.count', -1) do
      delete :destroy, id: @craft_category
    end

    assert_redirected_to craft_categories_path
  end
end
