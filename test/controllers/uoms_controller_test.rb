require 'test_helper'

class UomsControllerTest < ActionController::TestCase
  setup do
    @uom = uoms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:uoms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create uom" do
    assert_difference('Uom.count') do
      post :create, uom: { deleted: @uom.deleted, name: @uom.name, note: @uom.note, val: @uom.val }
    end

    assert_redirected_to uom_path(assigns(:uom))
  end

  test "should show uom" do
    get :show, id: @uom
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @uom
    assert_response :success
  end

  test "should update uom" do
    patch :update, id: @uom, uom: { deleted: @uom.deleted, name: @uom.name, note: @uom.note, val: @uom.val }
    assert_redirected_to uom_path(assigns(:uom))
  end

  test "should destroy uom" do
    assert_difference('Uom.count', -1) do
      delete :destroy, id: @uom
    end

    assert_redirected_to uoms_path
  end
end
