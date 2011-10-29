module Consular
  module ITermDSL

    # Generates a pane in the terminal. These can be nested to
    # create horizontal panes. Vertical panes are created with each top
    # level nest.
    #
    # @param [Array<String>] args
    #   Array of comamnds
    # @param [Proc] block
    #   Block of code to execute in pane context.
    #
    # @example
    #
    #   pane "top"
    #   pane { pane "uptime" }
    #
    # @api public
    def pane(*args, &block)
      @_context[:panes] = {} unless @_context.has_key? :panes
      panes             = @_context[:panes]
      pane_name         = "pane#{panes.keys.size}"

      if block_given?
        pane_contents = panes[pane_name] = {:commands => []}
        if @_context.has_key? :is_top_pane
          run_context pane_contents[:commands], &block
        else
          pane_contents[:is_top_pane] = true
          run_context pane_contents, &block
        end
      else
        panes[pane_name] = { :commands => args }
      end
    end

  end
end

Consular::DSL.class_eval { include Consular::ITermDSL }
