module Jsbundling
  module Tasks
    extend self

    attr_writer :build_command

    def install_command
      case tool
      when :bun then "bun install"
      when :yarn then "yarn install"
      when :pnpm then "pnpm install"
      when :npm then "npm install"
      else raise "jsbundling-rails: No suitable tool found for installing JavaScript dependencies"
      end
    end

    def build_command
      if @build_command
        return @build_command
      end

      case tool
      when :bun then "bun run build"
      when :yarn then "yarn build"
      when :pnpm then "pnpm build"
      when :npm then "npm run build"
      else raise "jsbundling-rails: No suitable tool found for building JavaScript"
      end
    end

    def tool_exists?(tool)
      system "command -v #{tool} > /dev/null"
    end

    def tool
      case
      when File.exist?('bun.lockb') then :bun
      when File.exist?('yarn.lock') then :yarn
      when File.exist?('pnpm-lock.yaml') then :pnpm
      when File.exist?('package-lock.json') then :npm
      when tool_exists?('bun') then :bun
      when tool_exists?('yarn') then :yarn
      when tool_exists?('pnpm') then :pnpm
      when tool_exists?('npm') then :npm
      end
    end
  end
end
