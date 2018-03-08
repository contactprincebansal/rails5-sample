class Gallery

  attr_accessor :text, :keys, :output, :visit_status, :result

  def initialize(text)
    @text = text
    @keys = %w(visitor_id room_id io timestamp)
    @output = {}
    @visit_status = {}
    @result = ""
  end

  def run
    text.each_line.with_index do |line, index|
      next unless line.gsub("\n", "").present?
      if index.zero?
        raise "Please input valid numbers of line (N)" if line.to_i.zero?
        next
      end
      line = line.gsub('I', '1').gsub('O', '0')
      check_visit_status(line)
    end
    set_result
  end

  def check_visit_status(line)
    visitor_id, room_id, io, timestamp = line.split(' ').collect(&:to_i)
    if visit_status["#{visitor_id}-#{room_id}"].present?
      old_timestamp = visit_status["#{visitor_id}-#{room_id}"]
      output[room_id] ||= {visitor_ids: [], timestamps: []}
      output[room_id][:visitor_ids] = (output[room_id][:visitor_ids] << visitor_id).uniq
      output[room_id][:timestamps] << (io == 0 ? timestamp - old_timestamp : old_timestamp - timestamp)
      visit_status.delete("#{visitor_id}-#{room_id}")
    else
      visit_status["#{visitor_id}-#{room_id}"] = timestamp
    end
    nil
  end

  def set_result
    output.sort_by{|k, v| k }.each do |k, v|
      average_mins = (v[:timestamps].sum/v[:visitor_ids].size).to_i
      visitors_count = v[:visitor_ids].size
      @result += "Room #{k}, #{average_mins} #{'minute'.pluralize(average_mins)} average visit, #{visitors_count} #{'visitor'.pluralize(visitors_count)} total\n"
    end
    result
  end

end