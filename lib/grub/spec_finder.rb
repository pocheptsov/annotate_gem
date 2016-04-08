module Grub
  module SpecFinder
    extend self

    def find_specs_for(gem_lines)
      gem_lines = Array(gem_lines)
      find_matching_specs_for(gem_lines)
      gems_to_fetch = gem_lines.select { |gem_line| gem_line.spec.nil? }
      fetch_specs_for(gems_to_fetch) if gems_to_fetch.any?
    end

    def find_matching_specs_for(gem_lines)
      gem_lines.each do |line|
        matching_specs = Gem::Dependency.new(line.name).matching_specs
        line.spec = matching_specs.first if matching_specs.any?
      end
    end

    def fetch_specs_for(gem_lines)
      print "Fetching gem metadata..."
      fetcher = Bundler::Fetcher.new(Gem.sources.first.uri)
      versions, _ = fetcher.send(:fetch_dependency_remote_specs, gem_lines.collect(&:name))
      gem_lines.each do |gem_line|
        print "."
        gem_versions = versions.select { |v| v.first == gem_line.name }
        version = find_latest_version(gem_versions)
        gem_line.spec = fetcher.fetch_spec([gem_line.name, version])
      end
      print "\n"
    end

    def find_latest_version(versions)
       versions.sort_by { |v| v[1] }.last[1]
    end
  end
end
