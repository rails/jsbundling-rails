require "puma/plugin"

Puma::Plugin.create do
  attr_reader :puma_pid, :jsbundling_pid, :log_writer

  def start(launcher)
    @log_writer = launcher.log_writer
    @puma_pid = $$
    @jsbundling_pid = fork do
      Thread.new { monitor_puma }
      # Using IO.popen(command, 'r+') will avoid watch_command read from $stdin.
      # If we use system(*command) instead, IRB and Debug can't read from $stdin
      # correctly bacause some keystrokes will be taken by watch_command.
      begin
        IO.popen(['bin/rails', 'javascript:watch'], 'r+') do |io|
          IO.copy_stream(io, $stdout)
        end
      rescue Interrupt
      end
    end

    if Gem::Version.new(Puma::Const::PUMA_VERSION) >= Gem::Version.new("7")
      launcher.events.after_stopped { stop_jsbundling }
    else
      launcher.events.on_stopped { stop_jsbundling }
    end

    in_background do
      monitor_jsbundling
    end
  end

  private
    def stop_jsbundling
      Process.waitpid(jsbundling_pid, Process::WNOHANG)
      log "Stopping jsbundling..."
      Process.kill(:INT, jsbundling_pid) if jsbundling_pid
      Process.wait(jsbundling_pid)
    rescue Errno::ECHILD, Errno::ESRCH
    end

    def monitor_puma
      monitor(:puma_dead?, "Detected Puma has gone away, stopping jsbundling...")
    end

    def monitor_jsbundling
      monitor(:jsbundling_dead?, "Detected jsbundling has gone away, stopping Puma...")
    end

    def monitor(process_dead, message)
      loop do
        if send(process_dead)
          log message
          Process.kill(:INT, $$)
          break
        end
        sleep 2
      end
    end

    def jsbundling_dead?
      Process.waitpid(jsbundling_pid, Process::WNOHANG)
      false
    rescue Errno::ECHILD, Errno::ESRCH
      true
    end

    def puma_dead?
      Process.ppid != puma_pid
    end

    def log(...)
      log_writer.log(...)
    end
end
