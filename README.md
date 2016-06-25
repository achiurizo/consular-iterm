# Consular - iTerm Core

Automate your iTerm Terminal with Consular


# Setup && Installation

If you haven't already, install Consular:

  gem install consular

then install consular-iterm:

  gem install consular-iterm


next, run `init`:

  consular init

This will generate a global directory and also a `.consularc` in your home
directory. On the top of your `.consularc`, just require this core like
so:

```ruby
# You can require your additional core gems here.
require 'consular/iterm'

# You can set specific Consular configurations
# here.
Consular.configure do |c|
end
```


## Additional Features

With `consular-iterm`, you can also genrate `panes` likes so:

```ruby
pane do
  run "top"
  pane "ps"
end

window do
  pane "gitx"
end
```

Splitting tabs into panes works as follows:

```ruby
window do
  pane "gitx"    # first pane
    pane do      # second pane level => horizontal split
      run "irb"
    end
  pane 'ls'      # first pane level => vertical split
end
```

should result into something like this:

    #    ###########################
    #    #            #            #
    #    #            #            #
    #    #   'gitx'   #            #
    #    #            #            #
    #    #            #            #
    #    ##############    'ls'    #
    #    #            #            #
    #    #            #            #
    #    #   'irb'    #            #
    #    #            #            #
    #    #            #            #
    #    ###########################

It is not possible to split the second level panes (the horizontal ones). 
Nevertheless you should be able to split tabs into any kind of pane pattern you wish
with this syntax.

Now you can use iTerm Terminal to run your Consular scripts!

## Compatibility

The current master branch is a work in progress towards iTerm2 v3 compatibility.  If you find any commands that don't work as you expect, please file an issue.  For a version compatible with iTerm2 v2, please use version `1.0.3`.

# Development

iTerm2 documentation for the Applescript API is [here](https://www.iterm2.com/documentation-scripting.html).  Ruby bindings for these methods are provided by `rb-scpt`.  Generally, the mapping of an Applescript command to a Ruby method is easily discoverable in a `bundle console` session in this repo.  A `pry` session is useful for exploring the methods on an `Appscript.app` method.

Test local changes with `rake spec` to run the test suite and `rake install` to build and install the gem locally.