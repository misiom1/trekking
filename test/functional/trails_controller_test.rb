require 'test_helper'

class TrailsControllerTest < ActionController::TestCase
  setup do
    @trail = trails(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trails)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trail" do
    assert_difference('Trail.count') do
      post :create, trail: @trail.attributes
    end

    assert_redirected_to trail_path(assigns(:trail))
  end

  test "should show trail" do
    get :show, id: @trail.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @trail.to_param
    assert_response :success
  end

  test "should update trail" do
    put :update, id: @trail.to_param, trail: @trail.attributes
    assert_redirected_to trail_path(assigns(:trail))
  end

  test "should destroy trail" do
    assert_difference('Trail.count', -1) do
      delete :destroy, id: @trail.to_param
    end

    assert_redirected_to trails_path
  end
end
