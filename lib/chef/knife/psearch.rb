# psearch.rb: A knife plugin for the Partial Search API
#
# Note that this is a Beta feature of Opscode Hosted Chef
# and that it's interface may changed based on user feedback.
#
# This plugin is not yes officially supported by Opscode

require 'chef/knife'
require 'chef/knife/core/node_presenter'

class Psearch < Chef::Knife
  banner "knife psearch INDEX SEARCH [NAME=DESIRED_KEY_PATH,[NAME=DESIRED_KEY_PATH]]"

  include ::Chef::Knife::Core::MultiAttributeReturnOption

  deps do
    require 'chef/node'
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

  option :id_only,
  :short => "-i",
  :long => "--id-only",
  :description => "Show only the ID of matching objects"

  option :rows,
  :short => "-R INT",
  :long => "--rows INT",
  :description => "The number of rows to return",
  :default => 1000,
  :proc => lambda { |i| i.to_i }

  DEFAULT_NODE_HASH = {
    "name" => ["name"],
    "chef_environment" => ["chef_environment"],
    "fqdn" => ["fqdn"],
    "ipaddress" => ["ipaddress"],
    "run_list" => ["run_list"],
    "roles" => ["roles"],
    "recipes" => ["recipes"],
    "platform" => ["platform"],
    "tags" => ["tags"]
  }

  # "id" will be used by the generic presenter automatically when
  # config[:id_only] is true
  ID_ONLY_HASH = {
    "id" => ["name"]
  }

  def run
    @index, @search, *@keys = @name_args
    @inflate_nodes = false

    args_hash = {}
    args_hash[:keys] = if config[:id_only]
                         ID_ONLY_HASH
                       elsif ! @keys.empty?
                         build_key_hash
                       elsif ! config[:attribute].nil? && ! config[:attribute].empty?
                         # config[:attribute] comes from the -a option,
                         # which is provided by Knife::Core::MultiAttributeReturnOption
                         build_key_hash_from_attrs(config[:attribute])
                       elsif @index == "node"
                         DEFAULT_NODE_HASH
                       else
                         nil
                       end

    # Create output similar to knife-search
    # in the default case by creating Chef::Node objects
    # and using the node presenter
    if args_hash[:keys] == DEFAULT_NODE_HASH && @index == 'node'
      Chef::Log.debug("Using NodePresenter for output")
      ui.use_presenter ::Chef::Knife::Core::NodePresenter
      @inflate_nodes = true
    end

    args_hash[:sort] = config[:sort]
    args_hash[:start] = config[:start]
    args_hash[:rows] = config[:rows]
    results = Chef::PartialSearch.new.search(@index, @search, args_hash)
    print_results(results.first)
  end

  def build_key_hash_from_attrs(attrs)
    key_hash = {}
    attrs.each do |a|
      key_hash[a] = a.split(".")
    end
    key_hash["id"] = [ "name" ] unless key_hash.has_key?("name")
    key_hash
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

  def print_results(items)
    items.each do |res|
      res = create_node(res) if @inflate_nodes
      ui.output ui.format_for_display(res)
      puts "\n" if ! config[:id_only]
    end
  end

  def create_node(node_data)
    node_data['attributes'] = node_data.reject do |key, value|
      ["name", "chef_environment", "run_list"].include?(key)
    end
    Chef::Node.json_create(node_data)
  end
end
