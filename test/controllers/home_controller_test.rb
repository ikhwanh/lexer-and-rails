require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "commands implementation" do
    post "/commands", params: { commands: "daftar nasi goreng harga 10000 es teh harga 2000 tambah nasi goreng jumlah 1 es teh jumlah 2 uang 50000" }
    assert_response :success
    body = { return: 36000 }
    assert_match /36000/, @response.body
  end
end
