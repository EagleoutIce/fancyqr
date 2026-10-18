# Changelog

## v2.5 (unreleased)

[Full Changelog](https://github.com/EagleoutIce/fancyqr/compare/v2.4...HEAD)

**New features:**

- Text beyond ASCII works with pdfLaTeX, LuaLaTeX and XeLaTeX. It is stored as UTF-8 and marked with an ECI header (on by default), so scanners no longer guess the character set; `eci=false` leaves the header out as a fallback for scanners that reject it (Google ML Kit reportedly does), at the cost that some scanners (ZBar) then garble non-ASCII text.
- New `halloween` style: orange and purple tiles with slime drips, finder cores that are pumpkins, jack-o'-lanterns, ghosts or skulls, and figures in the tile colors on the blocks that fit them (grim reapers, graves, witch hats, bats, spiders, skulls, candies, broken bones, ghosts and more).
- New `snow` style: snow lies on the top edges of the tiles, not on the top row, with ice running down over the tiles and merging with the snow (round drops, sharp and blunt spikes) and pale drips of melting snow of varied length below. The gradient is not changed.
- New `castle` style: masonry in a running bond whose colors follow the gradient, with battlements, towers, turrets, keeps, gatehouses, halls, castles and citadels, and finder patterns drawn as fortresses with a moat and drawbridge.
- New `christmas` style: pine and teal tiles with gold and cranberry accents, and snow on top by default that follows the tile edges. Tiered trees with trunks and stars, candy canes in six orientations, presents, baubles, sledges, a bench, toy trains, drums, stockings and nutcrackers. Light chains hang across the gaps between tiles, and stars, snowflakes and candles sit in open white, all of them pale so that scanners read the white modules safely. The timing patterns carry lights, and the finder cores are drawn at random (baubles, light rings, gifts, snowflakes, candy canes).
- `christmas` and `halloween` ship more figures and finder designs, drawn from the seeded generator, so `seed=` reproduces a code.
- `halloween` adds reapers, big and small jack-o'-lanterns, ghosts (including a happy big ghost), graves (rare), crosses, witch hats, witches with a cauldron, flying witches, brooms, fences, candelabras, scythes, lanterns, street lamps, bats (open-wing, flying, hanging), spiders in varied poses, skulls, eyeballs and eyes, bones with varied breaks, many candies, small single-module figures (pumpkins, potions, candles, a devil blob), and decorations: spider webs sized to the free white space, long hanging threads, slime and timing figures.
- `castle` adds houses, tents, wells, huts, wooden watchposts on stilts, stone turrets under spires, trees, mountain ranges and volcanoes on free-standing modules, a rare dragon (two at most) and training grounds (an archery target, a dummy or both), crop fields, courtyards of packed earth that run on under the walls around them, banners, rivers with forks, ponds and faint waves, alignment patterns as ponds with a boat, finder fortresses with more windows and a drawbridge mostly at the bottom, archers and knights guarding the walls, figures on tower tops, and a rare princess in a tower window. It is on grass by default, and user colors are respected.
- The `goo` style has drips of many kinds (sags, strands, double drips and more), varied per tile.
- New `pumpkin` shape for `finder core`.
- New `finder core color` option to color the cores apart from the rings.
- New `alignment color` and `alignment core color` options, so the alignment patterns can differ from the finder patterns.
- New `background` and `background radius` options: a fill behind the whole code, including the padding, with rounded corners by default (`background radius`, default `1` module; `0` for square).
- New `\FancyQrIfTiming{<true>}{<false>}` for style authors: picks `<true>` if the current tile is part of a timing pattern.
- New option `timing color` for the timing patterns, the dotted lines between the finder patterns.
- New `alignment` option: `finder` (default) styles the alignment patterns like the finder patterns, `inherit` draws them like the data, and `hide` replaces them with modules that look like data.
- New figure macros for style authors: `\FancyQrFigure` (with a starred form for grid positions), `\FancyQrFigureTile`, `\FancyQrFigureAt` and `\FancyQrDiagonals`.
- `finder core` also applies when the rings keep the tiles of the style.
- Data tiles merge into the straight sides of a finder ring instead of rounding off next to it.
- `\FancyQrStyleSet` lets a style set colors and finder shapes that are undone when the next style is loaded.
- Codes are recorded in files of their own (`<jobname>-fqr-<hash>.fqr`) and replayed in later runs (`persist`, on by default), so only the first run draws them; `externalize` also turns them into pdfs of their own. The manual is built that way.
- New `figures`, `no figures`, `extras` and `no extras` options select the figures and decorations of a style by name, and `figure chance` sets how often figures are drawn. `\FancyQrListFigures`, `\FancyQrListExtras`, `\FancyQrShowFigure`, `\FancyQrShowPattern`, `\FancyQrFigureGallery`, `\FancyQrExtraGallery` and `\FancyQrTileGallery` list and draw them. The manual shows every figure, tile and decoration of each style, generated from the style files.
- New `faint` option: the code in a faint grey, but the figures put with `place` in full colors.
- The figure galleries print the default chance of every figure and draw the module grid over it.
- `snow` puts a small snowflake on some tiles (extra `flakes`). Added to another style, its snow lies only on flat tops such as battlements, never on spires, roofs or figures, and no icicles hang below towers.
- New `add` option and `\FancyQrAdd`: the decorations of `halloween` (webs, threads, slime), `christmas` (lights, stars, snowflakes, candles) and `snow` (snow on the tiles) on any other style, such as castle walls with spider webs. Style authors lend decorations with `\FancyQrLend`.
- New `background margin` option (default `3.5pt`): the background reaches that far beyond the code.
- New `place` option puts a figure at a module, or at the closest place it fits. New `style` option sets a style for one code only; the other options override it. New macros for style authors: `\FancyQrExtra`, `\FancyQrIfExtra`, `\FancyQrExtras` and `\FancyQrSince`.

**Fixed bugs:**

- Alignment patterns were not styled on the first LaTeX run, and could take the positions of a previous code.
- With `\FancyQrDoNotPrintSquare` and finder shapes, the alignment shape was drawn inside the hole and damaged the cached matrix, so the next code with the same text failed with "Missing number". A shape that reaches into the hole is now left out.
- `\FancyQrDoNotPrintRadius` hid only a few modules around the center instead of the rounded rectangle.
- `\FancyQrLoad` in running text added stray spaces, because lines of the style files ended without `%`.
- `\FancyQrLoadDefault` did not reset the drawing passes, so after `glows` every tile was drawn more than once.
- Text beyond ASCII broke LuaLaTeX and XeLaTeX, and was read as the wrong character set on pdfLaTeX.
- The random styles used a pdfTeX-only primitive, so they failed on LuaLaTeX and XeLaTeX. All styles now work with pdfLaTeX, LuaLaTeX and XeLaTeX.
- Corrected the inner rounding of the `default` style.
- The straight part of a round finder ring where data tiles merge is computed from its real corner radius, so there are no notches next to round rings.
- `dots` and `blobs` left their finder settings to the next style. `\FancyQrStyleSet` now also restores finder thickness, finder radius and alignment colors when the next style loads.

**Tests:**

- New tests for the finder colors (counted per module), the alignment modes, merging into the rings, the pumpkin, style switching, the snow and halloween styles (skull and ghost counts checked against the matrix, snow caps), the hole fix, loading a style in running text, and alignment patterns on the first run.
- The figure API is checked against a separate Python model of the placement. Castle and christmas have smoke tests. Snow cap counts are checked against the matrix, and alignment colors have their own tests.
- Text beyond ASCII is tested on pdfTeX, LuaTeX and XeTeX (`config-unicode.lua`).
- `l3build scan` (tests/scan/scancheck.py) scans 1000 random codes over all styles with zxing and ZBar at 100, 150 and 300 dpi.

**Documentation:**

- Rewritten in plain language, with a single table for the finder and alignment keys, a new section on text beyond ASCII, and an option table that breaks across pages instead of running into the footer.
- The manual is built with `l3build doc` and uses the `xlistings` package, included as a git submodule (clone with `--recurse-submodules`). It has side-by-side examples and an index of commands and keys.
- The manual links every command and key in the text and examples to its explanation (code links from the `xlistings` submodule).
- Even spacing in the figure captions.

**Closed issues and merged pull requests:**

- chore\(deps\): bump actions/checkout from 6 to 7 [\#58](https://github.com/EagleoutIce/fancyqr/pull/58) ([dependabot[bot]](https://github.com/apps/dependabot))
- The `gh-pages` branch is published as an orphan branch, and Git LFS is no longer used.

## [v2.4](https://github.com/EagleoutIce/fancyqr/tree/v2.4) (2026-08-17)

[Full Changelog](https://github.com/EagleoutIce/fancyqr/compare/v2.3...v2.4)

**Fixed bugs:**

- Regression: marginpagerestore fix for beamer [\#55](https://github.com/EagleoutIce/fancyqr/issues/55)

**Closed issues:**

- Documentation link in README does not work [\#57](https://github.com/EagleoutIce/fancyqr/issues/57)
- Improved doc [\#53](https://github.com/EagleoutIce/fancyqr/issues/53)

**Merged pull requests:**

- chore\(deps\): bump actions/checkout from 6 to 7 [\#56](https://github.com/EagleoutIce/fancyqr/pull/56) ([dependabot[bot]](https://github.com/apps/dependabot))
- Improve Documentation [\#54](https://github.com/EagleoutIce/fancyqr/pull/54) ([EagleoutIce](https://github.com/EagleoutIce))
- chore\(deps\): bump actions/upload-artifact from 4 to 7 [\#52](https://github.com/EagleoutIce/fancyqr/pull/52) ([dependabot[bot]](https://github.com/apps/dependabot))
- Refine ci [\#51](https://github.com/EagleoutIce/fancyqr/pull/51) ([koppor](https://github.com/koppor))

## [v2.3](https://github.com/EagleoutIce/fancyqr/tree/v2.3) (2026-02-27)

[Full Changelog](https://github.com/EagleoutIce/fancyqr/compare/v2.2...v2.3)

**Closed issues:**

- Switch to LPPL [\#49](https://github.com/EagleoutIce/fancyqr/issues/49)
- Colored boxes [\#46](https://github.com/EagleoutIce/fancyqr/issues/46)
- Error in the doc? [\#43](https://github.com/EagleoutIce/fancyqr/issues/43)

**Merged pull requests:**

- Switch to LPPL [\#50](https://github.com/EagleoutIce/fancyqr/pull/50) ([EagleoutIce](https://github.com/EagleoutIce))
- doc-fix: fix style and macro highlight [\#44](https://github.com/EagleoutIce/fancyqr/pull/44) ([EagleoutIce](https://github.com/EagleoutIce))

## [v2.2](https://github.com/EagleoutIce/fancyqr/tree/v2.2) (2024-11-27)

[Full Changelog](https://github.com/EagleoutIce/fancyqr/compare/v2.1...v2.2)

**Closed issues:**

- Broken example files  [\#39](https://github.com/EagleoutIce/fancyqr/issues/39)
- Squares generated with `classic` option slightly too large [\#38](https://github.com/EagleoutIce/fancyqr/issues/38)
- Allow to configure overlap of tiles \(to make random colors work better\) [\#17](https://github.com/EagleoutIce/fancyqr/issues/17)
- Allow for circular cut-outs not just rectangle [\#5](https://github.com/EagleoutIce/fancyqr/issues/5)

**Merged pull requests:**

- Rounded Cutoff [\#41](https://github.com/EagleoutIce/fancyqr/pull/41) ([EagleoutIce](https://github.com/EagleoutIce))
- New `compensate` option, no overlap with `classic` [\#40](https://github.com/EagleoutIce/fancyqr/pull/40) ([EagleoutIce](https://github.com/EagleoutIce))

## [v2.1](https://github.com/EagleoutIce/fancyqr/tree/v2.1) (2024-10-05)

[Full Changelog](https://github.com/EagleoutIce/fancyqr/compare/v2.0...v2.1)

**Implemented enhancements:**

- Add a `classic` option [\#34](https://github.com/EagleoutIce/fancyqr/issues/34)
- Using one picture environment for the QR-Code [\#28](https://github.com/EagleoutIce/fancyqr/pull/28) ([EagleoutIce](https://github.com/EagleoutIce))

**Closed issues:**

- QR Rounding breaks after generating a QR Code of 64 or more chars [\#36](https://github.com/EagleoutIce/fancyqr/issues/36)
- Doc: Some of the important qr parameters like padding [\#32](https://github.com/EagleoutIce/fancyqr/issues/32)
- Blob Pattern Is Shifted Down [\#30](https://github.com/EagleoutIce/fancyqr/issues/30)
- Blobs appear to be a little bit "too-heavy" [\#24](https://github.com/EagleoutIce/fancyqr/issues/24)
- Join tile pictures into one large picture [\#23](https://github.com/EagleoutIce/fancyqr/issues/23)

**Merged pull requests:**

- fix: printing small qr code after big qr code broke rounding [\#37](https://github.com/EagleoutIce/fancyqr/pull/37) ([EagleoutIce](https://github.com/EagleoutIce))
- New `classic` option [\#35](https://github.com/EagleoutIce/fancyqr/pull/35) ([EagleoutIce](https://github.com/EagleoutIce))
- Document important options of the `qrcode` package [\#33](https://github.com/EagleoutIce/fancyqr/pull/33) ([EagleoutIce](https://github.com/EagleoutIce))
- Fix: blob pattern vertical center [\#31](https://github.com/EagleoutIce/fancyqr/pull/31) ([EagleoutIce](https://github.com/EagleoutIce))
- Reduce Size of Blobs [\#29](https://github.com/EagleoutIce/fancyqr/pull/29) ([EagleoutIce](https://github.com/EagleoutIce))

## [v2.0](https://github.com/EagleoutIce/fancyqr/tree/v2.0) (2024-04-13)

[Full Changelog](https://github.com/EagleoutIce/fancyqr/compare/v1.2...v2.0)

**Implemented enhancements:**

- Remove tikz dependency [\#22](https://github.com/EagleoutIce/fancyqr/pull/22) ([EagleoutIce](https://github.com/EagleoutIce))
- Random colors [\#13](https://github.com/EagleoutIce/fancyqr/pull/13) ([EagleoutIce](https://github.com/EagleoutIce))

**Merged pull requests:**

- feat: `width` and `size` as alias for `height` [\#20](https://github.com/EagleoutIce/fancyqr/pull/20) ([EagleoutIce](https://github.com/EagleoutIce))
- Small typo in the documentation: the name of the style is `blobs`, not `blob` [\#18](https://github.com/EagleoutIce/fancyqr/pull/18) ([jejust](https://github.com/jejust))
- provide fallback for clap [\#12](https://github.com/EagleoutIce/fancyqr/pull/12) ([EagleoutIce](https://github.com/EagleoutIce))

## [v1.2](https://github.com/EagleoutIce/fancyqr/tree/v1.2) (2024-04-13)

[Full Changelog](https://github.com/EagleoutIce/fancyqr/compare/v1.1...v1.2)

**Implemented enhancements:**

- Width Alias for qrcode Height [\#19](https://github.com/EagleoutIce/fancyqr/issues/19)

**Fixed bugs:**

- QR code seems to be off-center sometimes [\#16](https://github.com/EagleoutIce/fancyqr/issues/16)
- No `\clap` on older texlive versions \(2020-\) [\#11](https://github.com/EagleoutIce/fancyqr/issues/11)
- Rounded Edge Bug? [\#2](https://github.com/EagleoutIce/fancyqr/issues/2)

**Closed issues:**

- Drop tikz [\#21](https://github.com/EagleoutIce/fancyqr/issues/21)
- True tikz mode [\#15](https://github.com/EagleoutIce/fancyqr/issues/15)

## [v1.1](https://github.com/EagleoutIce/fancyqr/tree/v1.1) (2022-08-19)

[Full Changelog](https://github.com/EagleoutIce/fancyqr/compare/v1.0...v1.1)

**Closed issues:**

- `\FancyQrLoad` not working [\#9](https://github.com/EagleoutIce/fancyqr/issues/9)

**Merged pull requests:**

- fix: add `*.code` to build.lua [\#10](https://github.com/EagleoutIce/fancyqr/pull/10) ([EagleoutIce](https://github.com/EagleoutIce))

## [v1.0](https://github.com/EagleoutIce/fancyqr/tree/v1.0) (2022-08-18)

[Full Changelog](https://github.com/EagleoutIce/fancyqr/compare/ab62130fa8993389c9ca1425bde22282abbde3ce...v1.0)

**Closed issues:**

- Add a license [\#6](https://github.com/EagleoutIce/fancyqr/issues/6)
- Create a documentation [\#4](https://github.com/EagleoutIce/fancyqr/issues/4)
- 📑 TeX [\#1](https://github.com/EagleoutIce/fancyqr/issues/1)

**Merged pull requests:**

- generate license information [\#8](https://github.com/EagleoutIce/fancyqr/pull/8) ([EagleoutIce](https://github.com/EagleoutIce))
- create a documentation [\#7](https://github.com/EagleoutIce/fancyqr/pull/7) ([EagleoutIce](https://github.com/EagleoutIce))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
