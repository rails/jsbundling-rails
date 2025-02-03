require "test_helper"
require "jsbundling/tasks"

class TasksTest < ActiveSupport::TestCase
  test "override build_command" do
    original_build_command = Jsbundling::Tasks.build_command
    Jsbundling::Tasks.build_command = "hello there"
    assert_equal("hello there", Jsbundling::Tasks.build_command)

    Jsbundling::Tasks.build_command = nil
    assert_equal(original_build_command, Jsbundling::Tasks.build_command)
  ensure
    Jsbundling::Tasks.build_command = nil
  end
end
