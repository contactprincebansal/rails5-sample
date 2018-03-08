require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest

  def test_index
    get "/"
    assert_equal 200, status
  end

  def test_upload
    attachment = fixture_file_upload('files/gallery_log.txt','text/plain')
    post "/home/upload", params: { attachment: attachment }
    follow_redirect!
    assert_equal 200, status
    assert_equal "File uploaded successfully.", flash[:notice]
    assert_equal "/home/output", path


    post "/home/upload", params: { attachment: nil }
    follow_redirect!
    assert_equal 200, status
    assert_equal "param is missing or the value is empty: attachment", flash[:alert]
    assert_equal "/", path


    attachment = fixture_file_upload('files/gallery_log_blank.txt','text/plain')
    post "/home/upload", params: { attachment: attachment }
    follow_redirect!
    assert_equal 200, status
    assert_equal "No content found in file.", flash[:alert]
    assert_equal "/", path

    
  end
end
