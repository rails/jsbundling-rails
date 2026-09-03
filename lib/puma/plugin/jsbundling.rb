require "puma/plugin"

Puma::Plugin.create do
  attr_reader :jsbundling_pid, :log_writer

  def start(launcher)
    @log_writer = launcher.log_writer
    @stopping = false
    # The watch process gets a pipe for $stdin instead of Puma's, so that it
    # can't take keystrokes from IRB or Debug. Puma holds the write end open
    # for as long as it runs, so `javascript:watch` never sees EOF while the
    # server is up -- and sees it as soon as the server is gone, even when Puma
    # is killed too abruptly to run its shutdown hooks.
    #
    # `close_others:` keeps the watch process from inheriting Puma's listening
    # sockets. Puma clears close-on-exec on them so that they survive a hot
    # restart, which means they're already open by the time plugins start. A
    # watch process that inherits one keeps the socket alive after Puma is
    # gone, and the next boot fails with "There is already a server bound to:".
    # Under puma-dev that's fatal, since every boot of the app shares a single
    # socket path.
    #
    # `pgroup:` puts the watch process into its own process group, so that
    # stop_jsbundling can signal the entire tree instead of only the process it
    # spawned.
    stdin, @stdin_writer = IO.pipe
    @jsbundling_pid = Process.spawn(
      "bin/rails", "javascript:watch",
      in: stdin, pgroup: true, close_others: true
    )
    stdin.close
    log "Started jsbundling (pid #{jsbundling_pid})"

    if Gem::Version.new(Puma::Const::PUMA_VERSION) >= Gem::Version.new("7")
      launcher.events.before_restart { stop_jsbundling }
      launcher.events.after_stopped { stop_jsbundling }
    else
      launcher.events.on_restart { stop_jsbundling }
      launcher.events.on_stopped { stop_jsbundling }
    end

    in_background do
      monitor_jsbundling
    end
  end

  private
    def stop_jsbundling
      @stopping = true
      pid, @jsbundling_pid = jsbundling_pid, nil
      return unless pid

      log "Stopping jsbundling..."
      @stdin_writer.close unless @stdin_writer.closed?
      signal_jsbundling pid, :TERM

      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 5
      until reaped?(pid) || Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
        sleep 0.1
      end

      unless reaped?(pid)
        signal_jsbundling pid, :KILL
        Process.waitpid(pid)
      end
    rescue Errno::ECHILD, IOError
    end

    # Signals the process group instead of the process, so that `yarn build
    # --watch` and the bundler it spawns stop along with `javascript:watch`.
    # The group id is the pid, since it was spawned with `pgroup: true`.
    def signal_jsbundling(pid, signal)
      Process.kill signal, -pid
    rescue Errno::ESRCH, Errno::ECHILD
    end

    def reaped?(pid)
      !!Process.waitpid(pid, Process::WNOHANG)
    rescue Errno::ECHILD
      true
    end

    def monitor_jsbundling
      loop do
        break if @stopping
        pid = jsbundling_pid
        break if pid.nil?

        if reaped?(pid)
          log "Detected jsbundling has gone away, stopping Puma..."
          Process.kill(:INT, $$)
          break
        end

        sleep 2
      end
    end

    def log(...)
      log_writer.log(...)
    end
end
