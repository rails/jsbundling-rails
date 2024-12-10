require "puma/plugin"

Puma::Plugin.create do
  attr_reader :puma_pid, :yarn_pid, :log_writer

  def start(launcher)
    @log_writer = launcher.log_writer
    @puma_pid = $$
    @yarn_pid = fork do
      Thread.new { monitor_puma }
      IO.popen("yarn build --watch", "r+") do |io|
        IO.copy_stream(io, $stdout)
      end
    end

    launcher.events.on_stopped { stop_yarn }

    in_background do
      monitor_yarn
    end
  end

  private
    def stop_yarn
      Process.waitpid(yarn_pid, Process::WNOHANG)
      log "Stopping Yarn..."
      Process.kill(:INT, yarn_pid) if yarn_pid
      Process.wait(yarn_pid)
    rescue Errno::ECHILD, Errno::ESRCH
    end

    def monitor_puma
      monitor(:puma_dead?, "Detected Puma has gone away, stopping Yarn...")
    end

    def monitor_yarn
      monitor(:yarn_dead?, "Detected Yarn has gone away, stopping Puma...")
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

    def yarn_dead?
      Process.waitpid(yarn_pid, Process::WNOHANG)
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
