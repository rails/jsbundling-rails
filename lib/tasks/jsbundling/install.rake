namespace :javascript do
  namespace :install do
    desc "Install shared elements for all bundlers"
    task :shared do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/install.rb",  __dir__)}"
    end

    desc "Install node-specific elements for bundlers that use node/yarn."
    task :node_shared do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/install_node.rb",  __dir__)}"
    end

    desc "Install Bun"
    task bun: "javascript:install:shared" do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/bun/install.rb",  __dir__)}"
    end

    desc "Install esbuild"
    task esbuild: ["javascript:install:shared", "javascript:install:node_shared"] do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/esbuild/install.rb",  __dir__)}"
    end

    desc "Install rollup.js"
    task rollup: ["javascript:install:shared", "javascript:install:node_shared"] do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/rollup/install.rb",  __dir__)}"
    end

    desc "Install Webpack"
    task webpack: ["javascript:install:shared", "javascript:install:node_shared"] do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/webpack/install.rb",  __dir__)}"
    end
  end
end
