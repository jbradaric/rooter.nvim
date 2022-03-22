## About

Inspired by [airblade/vim-rooter](https://github.com/airblade/vim-rooter)

Also provides `Rooter` command and `FindRootDirectory()` function to remain compatible with vim-rooter.

## Usage

#### Use default settings

```lua
  require('rooter').setup()
```

#### Use custom settings

```lua
  require('rooter').setup({
    patterns = {'.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'CMakeLists.txt', 'package.json', 'Cargo.toml'},
    cd_command = 'cd',
    change_dir_for_non_project_files = '',
    chdir_on_buf_enter = true,
    vim_rooter_compat = true,
  })
```
