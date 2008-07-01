class JSLint
  def self.test(file_name)
    externals_path = File.dirname(__FILE__)

    rhino = File.join(externals_path, 'rhino.jar')
    jslint = File.join(externals_path, 'jslint.js')

    output = `java -jar #{rhino} #{jslint} #{file_name}`
    
    output.match('No problems found') ? true : output
  end

  def self.test_path(path_spec)
    failed = false

    javascript_path = File.join(RAILS_ROOT, path_spec)
    Dir["#{javascript_path}/*.js"].each do |file|
      unless failed
        puts "Testing #{file}"
        output = self.test(file)
        if output != true
          puts output
          failed = true
        end
      end
    end

    return !failed
  end
end
