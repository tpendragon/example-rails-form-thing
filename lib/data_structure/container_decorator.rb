require "draper"
require_relative "container"

# Thin wrapper to provide DataStructure::Container methods via a Draper
# decorator.  Necessary to deal with Rails magic while also allowing for
# multiple decorators on our models (one defining structure, one for the view
# magic, potentially others?)
module DataStructure
  class ContainerDecorator < Draper::Decorator
    include DataStructure::Container

    # This makes for a very messy object, but we need to allow anything through
    # to ensure multiple decorators can be used on one model.
    delegate_all
  end
end
