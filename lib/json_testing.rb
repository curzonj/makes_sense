module JsonResponseTestHelper
  def assert_json_success
    assert_response :success
    assert json_response['success']
  end

  def assert_json_failure
    assert_response :success
    assert_equal false, json_response['success']
  end

  def json_response
    ActiveSupport::JSON.decode(@response.body)
  end
end
