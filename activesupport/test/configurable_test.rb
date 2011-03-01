require 'abstract_unit'
require 'active_support/configurable'

class ConfigurableActiveSupport < ActiveSupport::TestCase
  class Parent
    include ActiveSupport::Configurable
    config_accessor :foo
  end

  class Child < Parent
  end

  setup do
    Parent.config.clear
    Parent.config.foo = :bar

    Child.config.clear
  end

  test "adds a configuration hash" do
    assert_equal({ :foo => :bar }, Parent.config)
  end

  test "configuration hash is inheritable" do
    assert_equal :bar, Child.config.foo
    assert_equal :bar, Parent.config.foo

    Child.config.foo = :baz
    assert_equal :baz, Child.config.foo
    assert_equal :bar, Parent.config.foo
  end

  test "configuration hash is available on instance" do
    instance = Parent.new
    assert_equal :bar, instance.config.foo
    assert_equal :bar, Parent.config.foo

    instance.config.foo = :baz
    assert_equal :baz, instance.config.foo
    assert_equal :bar, Parent.config.foo
  end

  test "configuration is crystalizeable" do
    parent = Class.new { include ActiveSupport::Configurable }
    child  = Class.new(parent)

    parent.config.bar = :foo
    assert !parent.config.respond_to?(:bar)
    assert !child.config.respond_to?(:bar)
    assert !child.new.config.respond_to?(:bar)

    parent.config.compile_methods!
    assert_equal :foo, parent.config.bar
    assert_equal :foo, child.new.config.bar

    assert_respond_to parent.config, :bar
    assert_respond_to child.config, :bar
    assert_respond_to child.new.config, :bar
  end
end