Gem::Specification.new do |s|
  s.name = %q{acts_as_gold}
  s.version = "1.0.5"
 
  s.specification_version = 2 if s.respond_to? :specification_version=
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ariejan de Vroom"]
  s.homepage = %q{http://ariejan.net}
  s.date = %q{2008-08-14}
  s.description = %q{acts_as_gold allows you to extend a model with money in the form of Gold, Silver and Copper, as seen in World of Warcraft}
  s.email = %q{ariejan@ariejan.net}
  s.extra_rdoc_files = ["README.textile"]
  s.files = ["Changelog", "LICENSE", "Rakefile", "README.textile", "lib/acts_as_gold.rb", "test/acts_as_gold_test.rb"]
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.textile"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.0.1}
  s.summary = %q{acts_as_gold extends a model with Gold, Silver and Copper money.}
  s.test_files = ["test/acts_as_gold_test.rb"]
  
  s.add_dependency(%q<activerecord>, [">= 1.0"])
end
