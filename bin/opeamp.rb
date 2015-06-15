#!/usr/bin/ env ruby

require "optparse"

class Log
  def initialize(offsetTime,data)
    @offsetTime  = offsetTime
    @data        = data
  end
  def csv(time)
    return "#{(time+@offsetTime)},#{@data.join(",")}"
  end
  def time(time)
    return time + @offsetTime
  end
end

begin
  params = Hash.new
  params[:time] = 1
  params[:output] = "output.csv"
  BUFFER_SIZE = 100000

  opts = OptionParser.new
  opts.on("-t VALUE", "--times VALUE", "SET VALUE of Times"){|t|
    params[:time] = t.to_i
  }
  opts.on("-o FILENAME", "--output FILENAME", "SET OUTPUT FILENAME"){|t|
    params[:output] = t
  }

  opts.parse!(ARGV)
  filename = ARGV[0]

  logs = Array.new
  headers = ""
  File.open(filename, "r"){|f|
    headers = f.gets.sub("\n","")
    beforeTime = -1
    while line = f.gets
      data = line.sub("\n","").split(",")
      time = data.shift
      if(beforeTime == -1)then
        offset = 0
        logs.push(Log.new(offset,data))
      else
        offset = time.to_i - beforeTime
        logs.push(Log.new(offset,data))
      end
      beforeTime = time.to_i
    end
  }
  buf = Array.new
  buf.push(headers)
  f = File.open(params[:output], "w")
  currentTime = 0
  params[:time].times do |i|
    p "TIMES:: #{i}"
    if(i != 0)then
      currentTime += 1
    end
    logs.each{|log|
      buf.push(log.csv(currentTime))
      currentTime = log.time(currentTime)
    }
    if(buf.size > BUFFER_SIZE)then
      f.write(buf.join("\n"))
      buf = Array.new
    end
  end
  if(buf.size > 0)then
    f.write(buf.join("\n"))
  end
  f.close
end
