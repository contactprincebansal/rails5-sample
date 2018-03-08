require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest

  def test_index
    get "/"
    assert_equal 200, status
  end

  def test_upload_simple
    attachment = fixture_file_upload('files/gallery_log.txt','text/plain')
    post "/home/upload", params: { attachment: attachment }
    follow_redirect!
    assert_equal 200, status
    assert_equal "File uploaded successfully.", flash[:notice]
    assert_equal "/home/output", path
  end

  def test_upload_check_with_no_file_input
    post "/home/upload", params: { attachment: nil }
    follow_redirect!
    assert_equal 200, status
    assert_equal "param is missing or the value is empty: attachment", flash[:alert]
    assert_equal "/", path
  end

  def test_upload_with_blank_file_input
    attachment = fixture_file_upload('files/gallery_log_blank.txt','text/plain')
    post "/home/upload", params: { attachment: attachment }
    follow_redirect!
    assert_equal 200, status
    assert_equal "No content found in file.", flash[:alert]
    assert_equal "/", path
  end

  def test_output
    get "/home/output"
    assert_equal "param is missing or the value is empty: file_name", flash[:alert]
    assert_equal 302, status
    follow_redirect!
    assert_equal "/", path
  end
end
