require "pathname"

module Jsbundling
  module PackageManager
    extend self

    MANAGERS = {
      bun: {
        add: "bun add %s",
        add_dev: "bun add %s --dev",
        install: "bun install",
        build: "bun run build"
      },
      pnpm: {
        add: "pnpm add %s",
        add_dev: "pnpm add -D %s",
        install: "pnpm install",
        build: "pnpm run build"
      },
      npm: {
        add: "npm install %s",
        add_dev: "npm install -D %s",
        install: "npm ci",
        build: "npm run build"
      },
      yarn: {
        add: "yarn add %s",
        add_dev: "yarn add --dev %s",
        install: "yarn install",
        build: "yarn build"
      }
    }.freeze

    def self.detect(root)
      if root.join("bun.lock").exist? || root.join("bun.lockb").exist? || root.join("bun.config.js").exist?
        :bun
      elsif root.join("pnpm-lock.yaml").exist?
        :pnpm
      elsif root.join("package-lock.json").exist?
        :npm
      else
        detect_by_executable || :yarn
      end
    end

    def detect_by_executable
      %i[ bun yarn pnpm npm ].each do |exe|
        return exe if system "command -v #{exe} > /dev/null"
      end

      nil
    end

    def package_manager
      @package_manager ||= PackageManager.detect(project_root)
    end

    def add_command(package, dev: false)
      if dev
        MANAGERS.dig(package_manager, :add_dev) % package
      else
        MANAGERS.dig(package_manager, :add) % package
      end
    end

    def install_command
      MANAGERS.dig(package_manager, :install)
    end

    def build_command(with_watch: false)
      package_build_command = MANAGERS.dig(package_manager, :build)

      if with_watch
        if package_manager == :npm || package_manager == :pnpm
          package_build_command += " -- --watch"
        else
          package_build_command += " --watch"
        end
      end

      package_build_command
    end

    private

    def project_root
      Pathname(!Rails.root.nil? ? Rails.root : Dir.pwd)
    end
  end
end
