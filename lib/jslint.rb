class JSLint
  def self.test(file_name)
    externals_path = File.dirname(__FILE__)

    rhino = File.join(externals_path, 'rhino.jar')
    jslint = File.join(externals_path, 'jslint.js')

    output = `java -jar #{rhino} #{jslint} #{file_name}`
    
    output.match('No problems found') ? true : output
  end

  def self.retest(pattern)
    failed = false

    Dir["#{RAILS_ROOT}/**/*.js"].each do |file|
      unless failed || !File.basename(file).match(pattern)
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


  def self.test_path(path_spec, ignore_list=[])
    failed = false

    javascript_path = File.join(RAILS_ROOT, path_spec)
    Dir["#{javascript_path}/*.js"].each do |file|
      unless failed or ignore_list.include?(File.basename(file))
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
