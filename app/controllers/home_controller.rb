class HomeController < ApplicationController

  BASE_PATH = "#{Rails.root}/tmp/gallery".freeze

  def index
  end

  def upload
    begin
      raise "Please input a valid file." unless home_params.present?
      file_name = "#{Time.now.to_i.to_s}.txt"
      crypto = Crypto.new
      raise "No content found in file." if File.size(home_params.tempfile).zero?
      text = home_params.tempfile.read
      text.gsub!(/\r\n?/, "\n")
      output_text = Gallery.new(text).run
      unless Dir.exists?(BASE_PATH)
        FileUtils.mkdir_p(BASE_PATH)
      end
      File.open("#{BASE_PATH}/#{file_name}", 'w+') { |file| file.write(output_text) && file.close }
    rescue => exception
      message = exception.message
    end
    if message.present?
      redirect_to root_path, alert: message
    else
      redirect_to output_home_index_path(file_name: crypto.encrypt(file_name, Rails.application.secrets.secret_key_base)), notice: 'File uploaded successfully.'
    end
  end

  def output
    begin
      raise "File name can not be blank." unless output_params.present?
      file_name = Crypto.new.decrypt(output_params, Rails.application.secrets.secret_key_base)
      @text = File.open("#{BASE_PATH}/#{file_name}", 'r').read
      @text.gsub!(/\r\n?/, "\n")
    rescue => exception
      message = exception.message
    end
    if message.present?
      redirect_to root_path, alert: message
    end
  end

  private
  def home_params
    params.require(:attachment)
  end

  def output_params
    params.require(:file_name)
  end

end
