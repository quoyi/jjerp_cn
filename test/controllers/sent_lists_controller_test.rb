require 'test_helper'

class SentListsControllerTest < ActionController::TestCase
  setup do
    @sent_list = sent_lists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sent_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sent_list" do
    assert_difference('SentList.count') do
      post :create, sent_list: { created_by: @sent_list.created_by, deleted: @sent_list.deleted, name: @sent_list.name, total: @sent_list.total }
    end

    assert_redirected_to sent_list_path(assigns(:sent_list))
  end

  test "should show sent_list" do
    get :show, id: @sent_list
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sent_list
    assert_response :success
  end

  test "should update sent_list" do
    patch :update, id: @sent_list, sent_list: { created_by: @sent_list.created_by, deleted: @sent_list.deleted, name: @sent_list.name, total: @sent_list.total }
    assert_redirected_to sent_list_path(assigns(:sent_list))
  end

  test "should destroy sent_list" do
    assert_difference('SentList.count', -1) do
      delete :destroy, id: @sent_list
    end

    assert_redirected_to sent_lists_path
  end
end
