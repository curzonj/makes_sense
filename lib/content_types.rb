require 'mime/types'
  
class << MIME::Types

  alias type_for_by_extension type_for

  def type_for(filename, platform=false)
    list = type_for_by_extension(filename, platform)
    list = File.get_mime_type(filename) if list.empty?

    list
  end
  alias of type_for

  def content_type_for(filename)
    type = type_for(filename)

    if type.empty?
      '' 
    else
      type.first.content_type
    end
  end
end

class << File
  def get_mime_type(path)
    return [] unless File.file?(path)

    output = `file -bi '#{path}'`.strip
    type = (output.nil? || output.match(/ERROR/)) ? nil : output

    type.nil? ? [] : MIME::Types[type]
  end

  def parse_extension(path)
    list = path.split(".")
    list.last if list.size > 1
  end
end
