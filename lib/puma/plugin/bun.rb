require "puma/plugin"

Puma::Plugin.create do
  attr_reader :puma_pid, :bun_pid, :log_writer

  def start(launcher)
    @log_writer = launcher.log_writer
    @puma_pid = $$
    @bun_pid = fork do
      Thread.new { monitor_puma }
      IO.popen("bun run build --watch", "r+") do |io|
        IO.copy_stream(io, $stdout)
      end
    end

    launcher.events.on_stopped { stop_bun }

    in_background do
      monitor_bun
    end
  end

  private
    def stop_bun
      Process.waitpid(bun_pid, Process::WNOHANG)
      log "Stopping Bun..."
      Process.kill(:INT, bun_pid) if bun_pid
      Process.wait(bun_pid)
    rescue Errno::ECHILD, Errno::ESRCH
    end

    def monitor_puma
      monitor(:puma_dead?, "Detected Puma has gone away, stopping Bun...")
    end

    def monitor_bun
      monitor(:bun_dead?, "Detected Bun has gone away, stopping Puma...")
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

    def bun_dead?
      Process.waitpid(bun_pid, Process::WNOHANG)
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
