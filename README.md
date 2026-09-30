# Neovim for Ruby / Rails / ERB / HTML

Neovim 0.12.5 built from source (`~/projects/neovim`) and installed to `~/neovim` (on `PATH` via `~/.zshrc`).
Leader is `<Space>`; press it and wait to see every mapping (which-key).

## Layout

```
init.lua                     leader, options, colorscheme, lazy.nvim
colors/sunburst.lua          TextMate Sunburst (colors from Sunburst.tmTheme)
lua/lualine/themes/sunburst.lua
lua/config/                  options, keymaps, autocmds, lazy bootstrap
  rails.lua                  Rails/Bundler task runner (<leader>r...)
  snippets.lua               TextMate-style <Tab> expansion (menu for ambiguous triggers)
  snippet_filetypes.lua      TextMate scope selectors -> snippet sets (models, migrations, ERB...)
lua/plugins/                 one file per area: treesitter, lsp, completion, formatting, rails, editor
after/queries/*/highlights.scm   extra captures so Ruby/Rails/HTML get TextMate's scopes
snippets/                    converted TextMate Ruby + Rails bundle snippets (VS Code JSON)
scripts/tmbundle2snippets.py the converter (see its header to regenerate)
```

## Language tooling

| | Highlighting | LSP | Format on save |
|---|---|---|---|
| Ruby / Rails | treesitter + Rails DSL captures | `ruby-lsp` (+ ruby-lsp-rails) | RuboCop via ruby-lsp (the project's `.rubocop.yml`); `rubocop` CLI outside a bundle |
| ERB | treesitter (`embedded_template` + html + ruby) | `ruby-lsp`, `html` | `htmlbeautifier` |
| HTML / CSS | treesitter | `html`, `cssls` (`vscode-langservers-extracted`) | `htmlbeautifier` (HTML) |

`<leader>uf` toggles format-on-save, `<leader>cf` formats now. `:ConformInfo`, `:checkhealth vim.lsp` for diagnostics.

## Snippets (TextMate bundles)

Type a trigger and press `<Tab>`: `def`, `cla`, `mod`, `ea`, `do`, `if`, `ife`, `r`, `w`, `rw`, ...
Rails triggers apply where TextMate's did: `bt`/`hm`/`vp` in models, `t.`/`tcs` in migrations,
`res`/`get` in routes, `ff`/`ffl`/`lt`/`rp` in views, `rp`/`rea`/`logd` in any Rails Ruby file.
When a trigger has several snippets (`cla`, `lt`, `t.`, ...) a picker opens.
`<Tab>`/`<S-Tab>` move between fields. Select text, press `<Tab>`, then expand a snippet to wrap it.
Removed Rails APIs (RJS, `render :text`, `find(:all)`, ...) were dropped; the rest were modernised.

## Keymaps

| Keys | Action |
|---|---|
| `<leader><space>` / `<C-p>` | find file |
| `<leader>fg` / `fw` / `fb` / `fr` | grep project / grep word / buffers / recent |
| `<leader>fm` / `fc` / `fv` / `fM` | Rails models / controllers / views / migrations |
| `<leader>e` | file tree (neo-tree) |
| `gd`, `K`, `grr`, `<leader>ca`, `<leader>cr` | definition, hover, references, code action, rename |
| `]h` `[h`, `<leader>gs` `gr` `gp` `gb` | next/prev hunk, stage/reset/preview hunk, blame |
| `<leader>gg` | lazygit |
| `<leader>ra` / `rr` | alternate / related file (vim-rails `:A` / `:R`) |
| `<leader>rgm` / `rgM` / `rgc` / `rgs` / `rgg` | generate migration / model / controller / scaffold / anything |
| `<leader>rdm` / `rdr` / `rdR` / `rds` / `rdS` | db:migrate / rollback / reset / status / seed |
| `<leader>rba` / `rbi` / `rbu` | `bundle add <gem>` / `bundle install` / `bundle update --all` |
| `<leader>rc` / `rt` / `rT` / `rR` | console / test this file / all tests / routes |

Rails commands run in a split at the bottom (`q` closes it). Generators open the file they created.

## Upgrading Neovim

```sh
cd ~/projects/neovim && git fetch --tags && git checkout v0.12.x
make distclean && make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$HOME/neovim && make install
```

Plugins: `:Lazy update` (versions are pinned in `lazy-lock.json`).
