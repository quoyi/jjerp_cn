require 'test_helper'

class SentsControllerTest < ActionController::TestCase
  setup do
    @sent = sents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sent" do
    assert_difference('Sent.count') do
      post :create, sent: { area: @sent.area, collection: @sent.collection, collection: @sent.collection, contact: @sent.contact, cupboard: @sent.cupboard, door: @sent.door, indent_id: @sent.indent_id, logistics: @sent.logistics, logistics_code: @sent.logistics_code, name: @sent.name, part: @sent.part, receiver: @sent.receiver, robe: @sent.robe, sent_at: @sent.sent_at }
    end

    assert_redirected_to sent_path(assigns(:sent))
  end

  test "should show sent" do
    get :show, id: @sent
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sent
    assert_response :success
  end

  test "should update sent" do
    patch :update, id: @sent, sent: { area: @sent.area, collection: @sent.collection, collection: @sent.collection, contact: @sent.contact, cupboard: @sent.cupboard, door: @sent.door, indent_id: @sent.indent_id, logistics: @sent.logistics, logistics_code: @sent.logistics_code, name: @sent.name, part: @sent.part, receiver: @sent.receiver, robe: @sent.robe, sent_at: @sent.sent_at }
    assert_redirected_to sent_path(assigns(:sent))
  end

  test "should destroy sent" do
    assert_difference('Sent.count', -1) do
      delete :destroy, id: @sent
    end

    assert_redirected_to sents_path
  end
end
