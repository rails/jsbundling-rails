say "Compile into app/assets/builds"
empty_directory "app/assets/builds"
keep_file "app/assets/builds"
append_to_file "app/assets/config/manifest.js", %(//= link_tree ../builds .js\n)

if Rails.root.join(".gitignore").exist?
  append_to_file ".gitignore", %(/app/assets/builds\n)
end

if (app_layout_path = Rails.root.join("app/views/layouts/application.html.erb")).exist?
  say "Add JavaScript include tag in application layout"
  insert_into_file app_layout_path.to_s, 
    %(\n    <%= javascript_include_tag "application", "data-track-turbo": "true", defer: true %>), before: /\s*<\/head>/
else
  say "Default application.html.erb is missing!", :red
  say %(        Add <%= javascript_include_tag "application", "data-track-turbo": "true", defer: true %> within the <head> tag in your custom layout.)
end

unless (app_js_entrypoint_path = Rails.root.join("app/javascript/application.js")).exist?
  say "Create default entrypoint in app/javascript/application.js"
  empty_directory app_js_entrypoint_path.parent.to_s
  copy_file "#{__dir__}/application.js", app_js_entrypoint_path
end
