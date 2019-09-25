# frozen_string_literal: true

module Pagemaster
  #
  #
  class Site
    attr_reader :config, :args, :opts, :collections

    #
    #
    def initialize(args, opts, config = nil)
      @args             = args
      @opts             = opts
      @config           = config || config_from_file
      @collections      = parse_collections
      @collections_dir  = @config.dig('collections_dir')
      @source_dir       = @config.dig('source_dir')

      if @args.empty?
        raise Error::MissingArgs, "You must specify one or more collections after 'jekyll pagemaster'"
      end

      if @collections.empty?
        raise Error::InvalidCollection, "Cannot find collection(s) #{@args} in config"
      end
    end

    #
    #
    def config_from_file
      puts("Reading configuration")
      return YAML.load_file("#{`pwd`.strip()}/_config.yml")
    end

    #
    #
    def parse_collections
      puts("Parsing collection")
      collections_config = @config.dig('collections')

      if collections_config.nil?
        raise Error::InvalidConfig, "Cannot find 'collections' key in _config.yml"
      end

      @args.map do |argument|
        puts("Processing argument #{argument}")
        unless collections_config.key?(argument)
          raise Error::InvalidArgument, "Cannot find requested collection #{argument} in _config.yml"
        end

        Collection.new(argument, collections_config.fetch(argument))
      end
    end

    #
    #
    def generate_pages
      paths = @collections.map do |collection_item|
        collection_item.generate_pages(@opts, @collections_dir, @source_dir)
      end.flatten
      puts Rainbow("Done ✔").green
      return paths
    end
  end
end
