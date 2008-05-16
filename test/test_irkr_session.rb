require File.dirname(__FILE__) + '/test_helper.rb'

class TestIrkrSession < Test::Unit::TestCase
  def test_should_not_call_new
    assert_raises(RuntimeError) do
      Irkr::Session.new
    end
  end
  
  def xtest_puts_on_session_puts_to_all_sockets
  end

  def xtest_quit_on_session_quits_all_sockets
  end
  
  def xtest_quit_for_nick_quits_single_socket
  end
end
