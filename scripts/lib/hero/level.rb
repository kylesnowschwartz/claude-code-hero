# frozen_string_literal: true

require 'json'

module Hero
  class Level
    include Checks

    class << self
      attr_reader :_number, :_name, :_feature, :_artifact, :_verify_block, :_clean_block

      def inherited(subclass)
        super
        registry << subclass
      end

      def registry
        @registry ||= []
      end

      def all
        registry.sort_by(&:_number)
      end

      def find(num)
        registry.find { |klass| klass._number == num }
      end

      # DSL methods
      def number(val)    = (@_number = val)
      def name(val)      = (@_name = val)
      def feature(val)   = (@_feature = val)
      def artifact(val)  = (@_artifact = val)
      def verify(&blk)   = (@_verify_block = blk)
      def clean(&blk)    = (@_clean_block = blk)
    end

    def initialize(dry_run: false)
      @dry_run = dry_run
      @actions = []
    end

    attr_reader :actions

    def number   = self.class._number
    def name     = self.class._name
    def feature  = self.class._feature
    def artifact = self.class._artifact

    def verify
      instance_eval(&self.class._verify_block)
      [true, 'PASS']
    rescue CheckFailed => e
      [false, e.message]
    end

    def clean
      @actions = []
      instance_eval(&self.class._clean_block) if self.class._clean_block
      @actions
    end

    def to_h
      { level: number, name: name, feature: feature, artifact: artifact }
    end
  end
end
