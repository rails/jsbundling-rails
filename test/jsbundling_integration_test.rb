require "test_helper"

class JsbundlingIntegrationTest < ActionDispatch::SystemTestCase
  test "renders the app" do
    visit root_url
    assert_text 'Welcome!'
  end
end
