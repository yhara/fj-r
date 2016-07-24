require 'bundler/setup'

file 'lib/fj-r/parser.ry' => 'lib/fj-r/parser.ry.erb' do
  sh "erb lib/fj-r/parser.ry.erb > lib/fj-r/parser.ry"
end

file 'lib/fj-r/parser.rb' => 'lib/fj-r/parser.ry' do
  sh "racc -g -o lib/fj-r/parser.rb lib/fj-r/parser.ry"
end

task :default => 'lib/fj-r/parser.rb' do
  sh "rspec"
end
