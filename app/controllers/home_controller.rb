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

  def improve_gallery
    visit_status = {}
    final_output = {}
    keys = %w(visitor_id room_id io timestamp)
    raise "No content found in file." if File.size(home_params.tempfile).zero?
    text = home_params.tempfile.read
    text.gsub!(/\r\n?/, "\n")
    text.each_line.with_index do |line, index|
      next unless line.gsub("\n", "").present?
      if index.zero?
        raise "Please input valid numbers of line (N)" if line.to_i.zero?
        next
      end
      line = line.gsub('I', '1').gsub('O', '0')
      visitor_id, room_id, io, timestamp = line.split(' ').collect(&:to_i)
      if visit_status["#{visitor_id}-#{room_id}"].present?
        old_timestamp = visit_status["#{visitor_id}-#{room_id}"]
        final_output[room_id] ||= {visitor_ids: [], timestamps: []}
        final_output[room_id][:visitor_ids] = (final_output[room_id][:visitor_ids] << visitor_id).uniq
        final_output[room_id][:timestamps] << (io == 0 ? timestamp - old_timestamp : old_timestamp - timestamp)
        visit_status.delete("#{visitor_id}-#{room_id}")
      else
        visit_status["#{visitor_id}-#{room_id}"] = timestamp
      end
    end
    result = ""
    final_output.sort_by{|k, v| k }.each do |k, v|
      average_mins = (v[:timestamps].sum/v[:visitor_ids].size).to_i
      visitors_count = v[:visitor_ids].size
      result += "Room #{k}, #{average_mins} #{'minute'.pluralize(average_mins)} average visit, #{visitors_count} #{'visitor'.pluralize(visitors_count)} total\n"
    end
    result
  end
end
