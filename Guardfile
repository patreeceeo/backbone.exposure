group :frontend do
  guard 'jasmine', :phantomjs_bin => '/usr/local/bin/phantomjs', :specdoc => :always, :console => :always do
    watch(%r{app/assets/javascripts/.+(js\.coffee|js)}) { "spec" }
    watch(%r{spec/javascripts/.+(js\.coffee|js)}) { "spec" }
  end
end
