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
require 'consular/osx'

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
tab do
	pane "gitx" # first pane
		pane do      # second pane level => horizontal split
			run "irb"
		end
	pane 'ls'   # first pane level => vertical split
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
