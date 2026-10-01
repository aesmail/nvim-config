# Neovim for Ruby / Rails / ERB / HTML / Flutter / Elixir / Phoenix

Neovim 0.12.5 built from source (`~/projects/neovim`) and installed to `~/neovim` (on `PATH` via `~/.zshrc`).
Leader is `<Space>`; press it and wait to see every mapping (which-key).

## Layout

```
init.lua                     leader, options, colorscheme, lazy.nvim
colors/sunburst.lua          TextMate Sunburst (colors from Sunburst.tmTheme)
lua/lualine/themes/sunburst.lua
lua/config/                  options, keymaps, autocmds, lazy bootstrap
  runner.lua                 terminal split for Rails/Mix tasks, bundler, flutter test
  rails.lua                  Rails/Bundler commands (<leader>r...)
  flutter.lua                Flutter helpers: widget actions, tests (<leader>F...)
  phoenix.lua                Phoenix/Mix commands (<leader>p..., mapped in keymaps.lua)
  snippets.lua               TextMate-style <Tab> expansion (menu for ambiguous triggers)
  snippet_filetypes.lua      TextMate scope selectors -> snippet sets (models, migrations, ERB...)
lua/plugins/                 one file per area: treesitter, lsp, completion, formatting, rails, flutter, debug, editor
after/queries/*/highlights.scm   extra captures so Ruby/Rails/HTML/Dart/Elixir/HEEx get TextMate's scopes
snippets/                    converted TextMate Ruby, Rails and Elixir bundle snippets (VS Code JSON)
scripts/tmbundle2snippets.py the converter (see its header to regenerate)
```

## Language tooling

| | Highlighting | LSP | Format on save |
|---|---|---|---|
| Ruby / Rails | treesitter + Rails DSL captures | `ruby-lsp` (+ ruby-lsp-rails) | RuboCop via ruby-lsp (the project's `.rubocop.yml`); `rubocop` CLI outside a bundle |
| ERB | treesitter (`embedded_template` + html + ruby) | `ruby-lsp`, `html` | `htmlbeautifier` |
| HTML / CSS | treesitter | `html`, `cssls` (`vscode-langservers-extracted`) | `htmlbeautifier` (HTML) |
| Dart / Flutter | treesitter | `dartls` via flutter-tools.nvim | `dart format` via dartls |
| Elixir | treesitter | `expert` (installed with mise) | Expert (`mix format` outside a Mix project) |
| HEEx / `~H` | treesitter (`heex` + elixir) | `expert`, `html`, `tailwindcss` | `mix format` (Phoenix's HEEx formatter plugin) |

`<leader>uf` toggles format-on-save, `<leader>cf` formats now. `:ConformInfo`, `:checkhealth vim.lsp` for diagnostics.

## Snippets (TextMate bundles)

Type a trigger and press `<Tab>`: `def`, `cla`, `mod`, `ea`, `do`, `if`, `ife`, `r`, `w`, `rw`, ...
Rails triggers apply where TextMate's did: `bt`/`hm`/`vp` in models, `t.`/`tcs` in migrations,
`res`/`get` in routes, `ff`/`ffl`/`lt`/`rp` in views, `rp`/`rea`/`logd` in any Rails Ruby file.
When a trigger has several snippets (`cla`, `lt`, `t.`, ...) a picker opens.
`<Tab>`/`<S-Tab>` move between fields. Select text, press `<Tab>`, then expand a snippet to wrap it.
Removed Rails APIs (RJS, `render :text`, `find(:all)`, ...) were dropped; the rest were modernised.
Elixir: `def`, `defp`, `defmod` (module name from the path: `lib/my_app/accounts/user.ex` ->
`MyApp.Accounts.User`), `do`, `fn`, `case`, `cond`, `ii`, `test`, `describe`, ...; LiveView additions
`mount`, `he`, `hi`, `render`; inside HEEx `{...}`/`<%= %>` the Elixir snippets apply, `ee` inserts `<% %>`.

## Flutter

flutter-tools.nvim runs the app through nvim-dap, so every run is a debug session:
saving a `.dart` file hot-reloads it, saving `pubspec.yaml` runs `flutter pub get`, and
breakpoints work without extra setup (the debug UI opens when execution stops).

- Widgets: `<leader>Fw` on a widget lists the analysis server's refactors — wrap with
  Center/Padding/Column/Row/SizedBox/Builder/…, remove this widget, move up/down, extract widget.
  (`<leader>ca` shows every code action.)
- Snippets from the analysis server expand with `<Tab>` too: `stless`, `stful`, `stanim`.
- Closing labels (`// Column`) and widget guides are drawn inline; `<leader>Fo` shows the widget tree.
- The statusline shows the device `:FlutterRun` will use. `<leader>Fd` picks another one.
- New macOS projects from `flutter create` may target macOS 10.15, which current Xcode rejects;
  set `MACOSX_DEPLOYMENT_TARGET = 12.0` in `macos/Runner.xcodeproj/project.pbxproj`.

## Elixir / Phoenix

- Mix tasks run in the bottom split: generators open the main file they created (`phx.gen.live/html/json`
  leave the output up, since it lists the routes to add to the router); they run in a focused terminal so
  you can answer phx.gen prompts.
- `<leader>pma` looks the package up on Hex, adds `{:pkg, "~> x.y"}` to `deps` in `mix.exs` and runs
  `mix deps.get`.
- Debugging uses ElixirLS's debug adapter (`mise use -g elixir-ls`; Expert has no debugger). Set a
  breakpoint (`<leader>db`), then `<leader>dc` and pick `phx.server`, `mix test (this file)`,
  `mix test (test at cursor)` or `mix test (all)`. Only modules with breakpoints run in the
  interpreter, so the app stays fast. The first session compiles ElixirLS (about a minute).
  ElixirLS writes a `.elixir_ls/` directory in the project; add it to `.gitignore`.
- Tailwind class completion works in projects the Tailwind language server can build. Phoenix 1.8's
  vendored daisyUI plugin (`@plugin "../vendor/daisyui"` in `assets/css/app.css`) currently stops it
  from matching any file; without that plugin (or in Rails/Tailwind projects) it works.

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
| `<leader>Fr` / `Fd` / `Fe` | flutter run / pick device and run / start emulator or simulator |
| `<leader>Fh` / `FR` / `Fq` | hot reload / hot restart / quit (saving also hot-reloads) |
| `<leader>Fw` / `Fo` / `Fl` / `FL` | widget actions / widget outline / toggle dev log / clear log |
| `<leader>Ft` / `FT` / `Fp` / `FP` | test this file / all tests / pub get / pub upgrade |
| `<leader>Fv` / `Fn` / `Fs` / `Fc` | DevTools / rename class + file / go to super / all Flutter commands |
| `<leader>pgm` / `pgs` / `pgc` / `pgl` / `pgh` / `pgj` / `pgg` | generate migration / schema / context / LiveView / HTML / JSON / any mix task |
| `<leader>pdm` / `pdr` / `pdR` / `pds` / `pdS` | ecto.migrate / rollback / reset / status / seed |
| `<leader>pma` / `pmg` / `pmu` | add Hex package / deps.get / deps.update --all |
| `<leader>pi` / `ps` / `pR` | IEx / server with IEx / routes |
| `<leader>pt` / `pn` / `pT` / `pa` | test this file / test at cursor / all tests / alternate (lib <-> test) |
| `<leader>db` / `dB` / `dc` | toggle breakpoint / conditional breakpoint / continue |
| `<leader>do` / `di` / `dO` / `dr` / `dl` / `dt` | step over / into / out / run to cursor / rerun last / terminate |
| `<leader>du` / `de` | toggle debug UI / evaluate expression |

Rails/Mix commands and `flutter test` run in a split at the bottom (`q` closes it).
Generators open the file they created.

## Upgrading Neovim

```sh
cd ~/projects/neovim && git fetch --tags && git checkout v0.12.x
make distclean && make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$HOME/neovim && make install
```

Plugins: `:Lazy update` (versions are pinned in `lazy-lock.json`).

## License

The configuration is released under the [MIT License](LICENSE).

The snippet files in `snippets/` are converted from TextMate's Ruby, Ruby on Rails and Elixir
bundles and stay under those bundles' licenses; `snippets/NOTICE.md` lists the sources, licenses
and what was changed. The Sunburst colors come from TextMate's Sunburst theme.
