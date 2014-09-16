require 'rb-fsevent'


class Watcher
  attr_accessor :now, :fsevent, :paths, :wip_enabled

  def initialize
    self.now = Time.now
    self.fsevent = FSEvent.new
    self.paths = [File.join(Dir.pwd, 'spec'), File.join(Dir.pwd, 'app')]
    self.wip_enabled = false
  end

  def rspec_options
    wip_enabled ? "-t wip" : ""
  end

  def start
    set_up_fsevent
    fsevent.run
  end

  def stop
    fsevent.stop
  end

  def set_up_fsevent
    fsevent.watch paths, no_defer: true do |directories|
      puts "Detected change inside: #{directories.inspect}"
      dir = directories.first[0...-1]
      difference = (now - Time.now).to_i
      files = `set -x && find #{dir} -type f -mtime #{difference}s`.split
      self.now = Time.now
      if files.any?
        file = files.first.strip
        file.sub!(/(.*)(app)\/(.*)\.rb$/, '\1spec/\3_spec.rb')
        if File.exists?(file)
          system %(set -x && spring rspec #{rspec_options} #{file})
        else
          puts "Couldn't find file: #{file}"
        end
      end
    end
  end

  def toggle_wip!
    self.wip_enabled = !wip_enabled
  end

  def wip_status
    wip_enabled ? :enabled : :disabled
  end
end

@watcher = Watcher.new

trap('QUIT') do
  @watcher.toggle_wip!
  puts "\rWip tag #{@watcher.wip_status}..."
end

@watcher.start
