# Changelog

## [1.0.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.18.2...v1.0.0) (2024-06-29)


### ⚠ BREAKING CHANGES

* remove the need for custom otter.nvim keybindings ([#135](https://github.com/quarto-dev/quarto-nvim/issues/135))

### Features

* remove the need for custom otter.nvim keybindings ([#135](https://github.com/quarto-dev/quarto-nvim/issues/135)) ([1665721](https://github.com/quarto-dev/quarto-nvim/commit/1665721f7ba16671f519f3cd87382bc28258af04))

## [0.18.2](https://github.com/quarto-dev/quarto-nvim/compare/v0.18.1...v0.18.2) (2024-02-19)


### Bug Fixes

* only require otter when activating ([5336b86](https://github.com/quarto-dev/quarto-nvim/commit/5336b86dc3d0517075debe8906671daeeab9f5ed))

## [0.18.1](https://github.com/quarto-dev/quarto-nvim/compare/v0.18.0...v0.18.1) (2024-02-19)


### Bug Fixes

* make disabling keybindings easier. refs [#116](https://github.com/quarto-dev/quarto-nvim/issues/116) ([1b15dd1](https://github.com/quarto-dev/quarto-nvim/commit/1b15dd175b974cb8c83b022f68cc07c02c9c465b))
* QuartoHover user function ([#113](https://github.com/quarto-dev/quarto-nvim/issues/113)) ([a4760c0](https://github.com/quarto-dev/quarto-nvim/commit/a4760c0b275972bc8ef577f7521771d17cb0cd17))

## [0.18.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.17.0...v0.18.0) (2023-11-29)


### Features

* configurable code runner with molten-nvim integration ([#99](https://github.com/quarto-dev/quarto-nvim/issues/99)) ([eacd8ff](https://github.com/quarto-dev/quarto-nvim/commit/eacd8ff211923c1b11a021ae6291bc34d9472948))


### Bug Fixes

* get current bufnr in ftplugin instead of relying on 0 ([af34813](https://github.com/quarto-dev/quarto-nvim/commit/af3481378ba7b664499fd1bbb9ae5fd6612d04fc))
* readme configruation ([#103](https://github.com/quarto-dev/quarto-nvim/issues/103)) ([1fe0f16](https://github.com/quarto-dev/quarto-nvim/commit/1fe0f163c42efdddb4d8b9ac8ac0e55eb20ff17c))
* user commands giving bad args to run funcs ([#101](https://github.com/quarto-dev/quarto-nvim/issues/101)) ([68ac6c0](https://github.com/quarto-dev/quarto-nvim/commit/68ac6c0500bcd0f3e978bd16c7d56e93ee8928da))

## [0.17.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.16.0...v0.17.0) (2023-09-08)


### Features

* pass arguments to quarto preview ([#88](https://github.com/quarto-dev/quarto-nvim/issues/88)) ([bad6f70](https://github.com/quarto-dev/quarto-nvim/commit/bad6f70269bcaf063513782c085aa2295ed3af25))

## [0.16.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.15.1...v0.16.0) (2023-08-27)


### Features

* format current code chunk ([4ba80ce](https://github.com/quarto-dev/quarto-nvim/commit/4ba80ce2ba73811228df88f4aa5294f528912417))

## [0.15.1](https://github.com/quarto-dev/quarto-nvim/compare/v0.15.0...v0.15.1) (2023-07-17)


### Bug Fixes

* clarify autcommand usage for setting keymaps ([d076de2](https://github.com/quarto-dev/quarto-nvim/commit/d076de2a43ad6b856b64da29dfa89cc1f6fba3f1))

## [0.15.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.14.1...v0.15.0) (2023-07-16)


### Features

* trigger release! ([fa9cc99](https://github.com/quarto-dev/quarto-nvim/commit/fa9cc994c4d76fa1e72778f5857cb8038451499f))

## [0.14.1](https://github.com/quarto-dev/quarto-nvim/compare/v0.14.0...v0.14.1) (2023-07-05)


### Bug Fixes

* fix [#76](https://github.com/quarto-dev/quarto-nvim/issues/76). Stick with vim.loop until stable release of nvim 0.10 (then it's vim.uv) ([aa42597](https://github.com/quarto-dev/quarto-nvim/commit/aa4259729e8b0878be8e06e98f601569059284b9))

## [0.14.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.13.2...v0.14.0) (2023-06-28)


### Features

* **lsp:** keybindings for ask_type_definition and ask_document_symbol ([2fd6169](https://github.com/quarto-dev/quarto-nvim/commit/2fd616956e65c9073d043eb631e251da6faa3404))


### Bug Fixes

* replace deprecated vim.loop with vim.uv ([1f043c8](https://github.com/quarto-dev/quarto-nvim/commit/1f043c81ec9e75046a6e1f315561e6333656d5c7))


### Performance Improvements

* put quarto init in ftplugin instea of autocommand ([1f2ccef](https://github.com/quarto-dev/quarto-nvim/commit/1f2ccefc22d3cad64bd10782b1670d8b6835cf1e))

## [0.13.2](https://github.com/quarto-dev/quarto-nvim/compare/v0.13.1...v0.13.2) (2023-06-21)


### Performance Improvements

* don't register quarto-&gt;markdown treesitter ft ([9f02823](https://github.com/quarto-dev/quarto-nvim/commit/9f02823d7b38b2e9c578bac085c430f14b74df3b))

## [0.13.1](https://github.com/quarto-dev/quarto-nvim/compare/v0.13.0...v0.13.1) (2023-06-06)


### Bug Fixes

* slime-sending. ([795133e](https://github.com/quarto-dev/quarto-nvim/commit/795133eaa3ee9995674d81f8718623f5aaf03bca))

## [0.13.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.12.0...v0.13.0) (2023-06-06)


### Features

* enable completion for html also if only activating `curly` chunks ([27ac79f](https://github.com/quarto-dev/quarto-nvim/commit/27ac79fb897cee6452d05711241ff6318cd25a9d))

## [0.12.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.11.0...v0.12.0) (2023-06-03)


### Features

* add html support through otter.nvim update (injections) ([f9fbdab](https://github.com/quarto-dev/quarto-nvim/commit/f9fbdab68d4af02733e1b983f494ecd56e8f1050))

## [0.11.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.10.1...v0.11.0) (2023-05-26)


### Features

* trigger release for otter.nvim rename and references ([2c013ae](https://github.com/quarto-dev/quarto-nvim/commit/2c013ae7f05554a78d9cb956ec73444513f336bf))

## [0.10.1](https://github.com/quarto-dev/quarto-nvim/compare/v0.10.0...v0.10.1) (2023-05-20)


### Bug Fixes

* remove duplicate queries (closes [#58](https://github.com/quarto-dev/quarto-nvim/issues/58)) ([9306dcc](https://github.com/quarto-dev/quarto-nvim/commit/9306dcc7272655e46712a26a15c65d801b8b7b2e))

## [0.10.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.9.0...v0.10.0) (2023-05-06)


### Features

* QuartoSendBelow and QuartoSendRange ([7226eee](https://github.com/quarto-dev/quarto-nvim/commit/7226eeecd42182c0051a0959983e15e9a4e0b939))


### Performance Improvements

* **diagnostics:** initialize diagnostic namespaces once and save ids ([f60eb6a](https://github.com/quarto-dev/quarto-nvim/commit/f60eb6a877c17af8c92490e96148172463b68627))

## [0.9.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.8.1...v0.9.0) (2023-04-20)


### Features

* QuartoSendAbove and QuartoSendAll commands to send code to ([cb2bb7d](https://github.com/quarto-dev/quarto-nvim/commit/cb2bb7d47f02b5abfa60fa80d24fe4b4b9120d92))

## [0.8.1](https://github.com/quarto-dev/quarto-nvim/compare/v0.8.0...v0.8.1) (2023-04-20)


### Bug Fixes

* quarto preview in Windows/PowerShell ([#53](https://github.com/quarto-dev/quarto-nvim/issues/53)) ([8980f73](https://github.com/quarto-dev/quarto-nvim/commit/8980f739045867b2c59612e380ecb32dbf3df803))

## [0.8.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.7.3...v0.8.0) (2023-04-09)


### Features

* nvim 0.9.0! ([#50](https://github.com/quarto-dev/quarto-nvim/issues/50)) ([ac9bafe](https://github.com/quarto-dev/quarto-nvim/commit/ac9bafe821aecfa7e3071d5b6e936588e0deff4c))

## [0.7.3](https://github.com/quarto-dev/quarto-nvim/compare/v0.7.2...v0.7.3) (2023-04-04)


### Bug Fixes

* activate quarto only once per buffer ([9de52c8](https://github.com/quarto-dev/quarto-nvim/commit/9de52c85423fbc218f7324be4af662c32aee3da9))
* remove debug statement ([a9f9f98](https://github.com/quarto-dev/quarto-nvim/commit/a9f9f98da951ee7146d519ddc624013e6bdcd6aa))

## [0.7.2](https://github.com/quarto-dev/quarto-nvim/compare/v0.7.1...v0.7.2) (2023-03-11)


### Bug Fixes

* fix package name for release ([96f741c](https://github.com/quarto-dev/quarto-nvim/commit/96f741cd04dd769e9ce1c1aaa913ee6296594a47))

## [0.7.1](https://github.com/quarto-dev/quarto-nvim/compare/v0.7.0...v0.7.1) (2023-03-11)


### Bug Fixes

* format and trigger release ([9e2adb0](https://github.com/quarto-dev/quarto-nvim/commit/9e2adb0e93e2d3c7ae1ce0471bcd8113faa03521))
* just use otter.ask_hover ([31ba845](https://github.com/quarto-dev/quarto-nvim/commit/31ba845274e2a1f77dd5ebe2890e182856776a15))

## [0.7.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.6.0...v0.7.0) (2023-02-15)


### Features

* use quarto filetype instead of markdown ([#26](https://github.com/quarto-dev/quarto-nvim/issues/26)) ([449e877](https://github.com/quarto-dev/quarto-nvim/commit/449e877005d544dc931be36177728482aec49a03))

## [0.6.0](https://github.com/quarto-dev/quarto-nvim/compare/v0.5.3...v0.6.0) (2023-01-25)


### Features

* add group for qmd open autocmd. ([#27](https://github.com/quarto-dev/quarto-nvim/issues/27)) ([467da36](https://github.com/quarto-dev/quarto-nvim/commit/467da365225d9606e074cdb8eb7cb3e520ecc270))
