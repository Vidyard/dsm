Gem::Specification.new do |s|
  s.name        = 'dsm'
  s.version     = '1.0.0'
  s.date        = '2015-12-04'
  s.summary     = "Helps migrate data on large mysql tables"
  s.description = <<-EOF
    Migrate data on large MySQL tables without downtime by making changes in small batches.
    Provides tools for throttling, displaying progress and completion estimation.
    Uses similar format to LHM (Large Hadron Migrator) https://github.com/soundcloud/lhm
  EOF
  s.authors     = ["Nathan Hoel"]
  s.email       = 'nathan.hoel@vidyard.com'
  s.files       = Dir['lib/**/*.rb']
  s.test_files  = Dir['spec/**/*_spec.rb']
  s.homepage    = 'https://github.com/Vidyard/dsm'
  s.license     = 'MIT'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency('rspec', '>= 3.1.0')
end
