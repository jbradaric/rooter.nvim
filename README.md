## About

Inspired by [airblade/vim-rooter](https://github.com/airblade/vim-rooter)

Also provides `Rooter` command and `FindRootDirectory()` function to remain compatible with vim-rooter.

## Usage

#### Use default root directory patterns

```lua
  require('rooter').setup()
```

#### Use custom patterns

```lua
  require('rooter').setup({
    patterns = {'.git', '.hg', 'Makefile'},
  })
```
