# psearch.rb: A knife plugin for the Partial Search API
#
# Note that this is a Beta feature of Opscode Hosted Chef
# and that it's interface may changed based on user feedback.
#
# This plugin is not yes officially supported by Opscode

class Psearch < Chef::Knife
  banner "knife psearch INDEX SEARCH NAME=DESIRED_KEY_PATH,[NAME=DESIRED_KEY_PATH]"

  deps do
    require 'chef/search/partial_search'
  end

  option :sort,
  :short => "-o SORT",
  :long => "--sort SORT",
  :description => "The order to sort the results in",
  :default => nil

  option :start,
  :short => "-b ROW",
  :long => "--start ROW",
  :description => "The row to start returning results at",
  :default => 0,
  :proc => lambda { |i| i.to_i }

  option :rows,
  :short => "-R INT",
  :long => "--rows INT",
  :description => "The number of rows to return",
  :default => 1000,
  :proc => lambda { |i| i.to_i }

  option :attribute,
  :short => "-a ATTR",
  :long => "--attribute ATTR",
  :description => "Show only one attribute"

  def run
    @index, @search, *@keys = @name_args
    args_hash = {}
    args_hash[:keys] = build_key_hash
    args_hash[:sort] = config[:sort]
    args_hash[:start] = config[:start]
    args_hash[:rows] = config[:rows]
    results = Chef::PartialSearch.new.search(@index, @search, args_hash)
    ui.output ui.format_for_display(results.first)
  end

  def build_key_hash
    key_hash = {}
    specs = @keys.map { |i| i.split(",") }.flatten
    specs.each do |spc|
      name, value = spc.split("=")
      key_hash[name] = value.split(".")
    end
    # This seems like a sane default.  The results without the name
    # are usually not what we want.
    key_hash["name"] = [ "name" ] unless key_hash.has_key?("name")
    key_hash
  end
end
