require 'consular'
require 'appscript'
require File.expand_path('../iterm_dsl', __FILE__)

module Consular

  # Consular Core to interact with iTerm2 for Mac OS X
  #
  class ITerm < Core
    include Appscript

    Consular.add_core self

    class << self

      # Checks to see if the current system is darwin and 
      # if $TERM_PROGRAM is iTerm.app
      #
      # @api public
      def valid_system?
        (RUBY_PLATFORM.downcase =~ /darwin/) && ENV['TERM_PROGRAM'] == 'iTerm.app'
      end

      # Returns the name of Core. Used in CLI core selection.
      #
      # @api public
      def to_s
        "Consular::ITerm Mac OSX iTerm2"
      end

    end

    # Initializes a reference to the iTerm.app via appscript
    #
    # @param [String] path
    #   Path to Termfile
    #
    # @api public
    def initialize(path)
      super
      @terminal = app('iTerm')
    end

    # Prepends the :before commands to the current context's
    # commands if it exists.
    #
    # @param [Array<String>] commands
    #   The current tab commands
    # @param [Array<String>] befores
    #   The current window's :befores
    #
    # @return [Array<String>]
    #   The current context commands with the :before commands prepended
    #
    # @api public
    def prepend_befores(commands, befores = nil)
      unless befores.nil? || befores.empty?
        commands.insert(0, befores).flatten! 
      else
        commands
      end
    end

    # Prepend a title setting command prior to the other commands.
    #
    # @param [String] title
    #   The title to set for the context of the commands.
    # @param [Array<String>] commands
    #   The context of commands to preprend to.
    #
    # @api public
    def set_title(title, commands)
      cmd = "PS1=\"$PS1\\[\\e]2;#{title}\\a\\]\""
      title ? commands.insert(0, cmd) : commands
    end

    # Executes the commands for each designated window.
    # .run_windows will iterate through each of the tabs in
    # sorted order to execute the tabs in the order they were set.
    # The logic follows this:
    #
    #   If the content is for the 'default' window,
    #   then use the current active window and generate the commands.
    #
    #   If the content is for a new window,
    #   then generate a new window and activate the windows.
    #
    #   Otherwise, open a new tab and execute the commands.
    #
    # @param [Hash] content
    #   The hash contents of the window from the Termfile.
    # @param [Hash] options
    #   Addional options to pass. You can use:
    #     :default - Whether this is being run as the default window.
    #
    # @example
    #   @core.execute_window contents, :default => true
    #   @core.execute_window contents, :default => true
    #
    # @api public
    def execute_window(content, options = {})
      window_options = content[:options]
      _contents      = content[:tabs]
      _first_run     = true

      _contents.keys.sort.each do |key|
        _content = _contents[key]
        _options = content[:options]
        _name    = options[:name]

        _tab =
        if _first_run && !options[:default]
          open_window options.merge(window_options)
        else
          key == 'default' ? active_window : open_tab(_options)
        end

        _first_run = false
        commands = prepend_befores _content[:commands], _contents[:befores]
        commands = set_title _name, commands

        if _contents.key? :panes
          execute_panes _contents
        else
          commands.each { |cmd| execute_command cmd, :in => _tab }
        end
      end

    end

    def first_pane_level_split(panes, tab_commands)
      first_pane = true
      split_v_counter = 0
      panes.keys.sort.each do |pane_key|
        pane_content = panes[pane_key]
        unless first_pane
          split_v
          split_v_counter += 1 
        end
        first_pane = false if first_pane
        pane_commands = pane_content[:commands] 
        execute_pane_commands(pane_commands, tab_commands)
      end
      split_v_counter.times { select_pane 'Left' }
    end

    def second_pane_level_split(panes, tab_commands)
      panes.keys.sort.each do |pane_key|
        pane_content = panes[pane_key]
        handle_subpanes(pane_content[:panes], tab_commands) if pane_content.has_key? :panes
        # select next vertical pane
        select_pane 'Right'
      end
    end

    def handle_subpanes(subpanes, tab_commands)
      subpanes.keys.sort.each do |subpane_key|
        subpane_commands = subpanes[subpane_key][:commands]
        split_h
        execute_pane_commands(subpane_commands, tab_commands)
      end
    end

    def execute_pane_commands(pane_commands, tab_commands)
      pane_commands = tab_commands + pane_commands
      pane_commands.each { |cmd| execute_command cmd}
    end



    # Split the active tab with vertical panes
    #
    # @api public
    def vertical_split
      call_ui_action "Shell", nil, "Split Vertically With Same Profile"
    end

    # Split the active tab with horizontal panes
    # 
    # @api public
    def horizontal_split
      call_ui_action "Shell", nil, "Split Horizontally With Same Profile"
    end

    # to select panes; iTerm's Appscript select method does not work
    # as expected, we have to select via menu instead
    # 
    # @param [String] direction
    #   Direction to split the pane. The valid directions are:
    #   'Above', 'Below', 'Left', 'Right'
    #
    # @api public
    def select_pane(direction)
      valid_directions = %w[Above Below Left Right]
      if valid_directions.include?(direction)
        call_ui_action("Window", "Select Split Pane", "Select Pane #{direction}")
      else
        puts "Error: #{direction} is not a valid direction to select a pane; Only Above/Below/Left/Right are valid directions"
      end
    end


    # Opens a new tab and focuses on it.
    #
    # @param [Hash] options
    #   Additional options to further customize the tab.
    #
    # @api public
    def open_tab(options = nil)
      active_window.launch_ :session => 'New session'
    end

    # Opens a new window and focuses
    # on the new tab.
    #
    # @param [Hash] options
    #   Additional options to further customize the window.
    #
    # @api public
    def open_window(options = nil)
      window = @terminal.make :new => :terminal
      window.launch_ :session => 'New session'
    end

    # Execute the given command in the context of the active window.
    #
    # @param [String] cmd
    #   The command to execute.
    # @param [Hash] options
    #   Additional options to pass into appscript for the context.
    #
    # @example
    #   @osx.execute_command 'ps aux', :in => @tab_object
    #
    # @api public
    def execute_command(cmd, options = {})
      context = options[:in] || active_window
      context.write :text => cmd
    end

    # Returns the active tab e.g the active terminal session.
    #
    # @api public
    def active_tab
      active_window.current_session
    end

    # Returns the active window/tab e.g the active terminal window.
    #
    # @api public
    def active_window
      @terminal.current_terminal
    end

    # Returns a reference to the iTerm menu bar.
    #
    # @api public
    def iterm_menu
      _process = app("System Events").processes["iTerm"]
      _process.menu_bars.first
    end

    # Execute the menu action via UI.
    #
    # @param [String] menu
    #   Top level menu name
    # @param [String] submenu
    #   Sub level menu name
    # @param [String] action
    #   Action name/description.
    #
    # @example
    #   @core.call_ui_action 'Edit', 'Find', 'Find Next'
    #   @core.call_ui_action 'Shell', nil, 'Split Vertically With Same Profile'
    #
    # @api public
    def call_ui_action(menu, submenu, action)
      menu = iterm_menu.menu_bar_items[menu].menus[menu]
      menu = menu.menu_items[submenu].menus[submenu] if submenu
      menu.menu_items[action].click
    end

  end
end
