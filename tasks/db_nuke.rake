namespace :db do
  task :nuke => :environment do
    abcs = ActiveRecord::Base.configurations
    ["development", "test"].each do |db|
      case abcs[db]["adapter"]
        when "oci", "oracle"
          ActiveRecord::Base.establish_connection(db.to_sym)
          conn = ActiveRecord::Base.connection
          conn.begin_db_transaction
          conn.tables.each do |table|
            indexes = conn.indexes(table)
            indexes.each do |ind|
              puts "Dropping index #{ind.name}"
              conn.execute("DROP INDEX #{ind.name}")
            end
            puts "Dropping table #{table}"
            conn.execute("DROP TABLE #{table}")
          end
          sql = "SELECT LOWER(sequence_name) FROM user_sequences"
          sequences = conn.select_all(sql).inject([]) do |seqs, s|
            seqs << s.to_a.first.last
          end
          sequences.each do |seq|
            puts "Dropping sequence #{seq}"
            conn.execute("DROP SEQUENCE #{seq}")
          end
          conn.commit_db_transaction
        when "mysql"
          ActiveRecord::Base.establish_connection(db.to_sym)
          conn = ActiveRecord::Base.connection
          conn.execute("DROP DATABASE #{abcs[db]["database"]}")
          conn.execute("CREATE DATABASE #{abcs[db]["database"]}")
          ActiveRecord::Base.establish_connection(db.to_sym)
        when "sqlite", "sqlite3"
          dbfile = abcs[db]["database"] || abcs[db]["dbfile"]
          File.delete(dbfile) if File.exist?(dbfile)
          ActiveRecord::Base.establish_connection(db.to_sym)
        else
          raise "Task not supported by '#{abcs[db]["adapter"]}'"
      end

      ENV['RAILS_ENV'] = db
      Rake::Task["db:migrate"].dup.invoke
      Rake::Task["db:fixtures:load"].dup.invoke
    end
  end
end
