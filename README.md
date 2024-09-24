# fancyqr

[![made-with-latex](https://img.shields.io/badge/Made%20with-LaTeX-1f425f.svg)](https://www.latex-project.org/) [![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/GPL-3.0) [![PR's Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com) [![CTAN](https://badgen.net/badge/On/CTAN/cyan)](https://www.ctan.org/pkg/fancyqr) [![compile qr](https://github.com/EagleoutIce/fancyqr/actions/workflows/compile.yaml/badge.svg)](https://github.com/EagleoutIce/fancyqr/actions/workflows/compile.yaml)

[<img src="https://github.com/EagleoutIce/fancyqr/blob/gh-pages/preview-1.png?raw=true" width="600"/>](qr-example.tex)

A simple package to create fancy qr-codes with the help of the [`qrcode`][qrcode]-package.
You may use `\fancyqr` just like the normal `\qrcode` (`\fancyqr[<qr-options>]{<url>}`). See the [documentation](https://media.githubusercontent.com/media/EagleoutIce/fancyqr/gh-pages/build/fancyqr-doc.pdf). If you just want to create a simple qr-code, please refer to the [minimal example](qr-minimal.tex).

*fancyqr* is actively developed by *Florian Sihler* (contact me at: <florian.sihler@uni-ulm.de>) under the [GPLv3 License](LICENSE). I am very happy about every contribution (see [CONTRIBUTING.md](CONTRIBUTING.md)). You can find it on CTAN (<https://www.ctan.org/pkg/fancyqr>).

If you do want to hide a center square (e.g., because you want to embed an image), you can use `\FancyQrDoNotPrintSquare{<x>}{<y>}` to hide a rectangle with radius x and y set from the center. If you choose this option, the default `\FancyQrRoundCut` that rounds cut corners can be changed with `\FancyQrHardCut`.
At the moment, there are six other styles (`flat`, `frame`, `blobs`, `glitch`, and `dots`) that you can load (locally) by using `\FancyQrLoad{<name>}`. The default style is named `default` and can be 'reset' by `\FancyQrLoad{default}` or `\FancyQrLoadDefault`.

There are the following extra qr-options (you can set all of them with `\fancyqrset{<keys>}`):

| Option            | Type        | Default  | Explanation                                                                                                                                |
| ----------------- | ----------- | :------: | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `classic`         | boolean     |  `false` | Use the classic qr-code style (black with flat rectangles, this loads the `flat` style).                                                    |
| `color`           | color       |          | Disables the `gradient` and sets the qr color accordingly.                                                                                 |
| `gradient angle`  | angle       |  `135`   | Change the gradient angle.                                                                                                                 |
| `gradient`        | boolean     |   true   | Toggle the color gradient                                                                                                                  |
| `image`           | LaTeX       |          | Automatically center an image (you have to care for the size and maybe adjust the `version` and `level` to keep the qr-code readable).[^1] |
| `image padding`   | number      |          | Additionally hide blocks (x & y) around the image.                                                                                         |
| `image x padding` | number      |   `0`    | Additionally hide blocks (x) around the image.                                                                                             |
| `image y padding` | number      |   `0`    | Additionally hide blocks (y) around the image.                                                                                             |
| `l color`         | color       | `purple` | Set the top left gradient color.                                                                                                           |
| `left color`      | color       |          | Alias for `l color`.                                                                                                                       |
| `level`           | L/M/Q/H     |   `M`    | [`qrcode`][qrcode] option affecting error correction (low, medium, quartile, high).                                                        |
| `padding`         | flag        |          | [`qrcode`][qrcode] option adding sufficient additional space around the qr-code.                                                           |
| `r color`         | color       |  `teal`  | Set the bottom right gradient color.                                                                                                       |
| `random color`    | colors      |          | Allow to set a random color pool to pick from.                                                                                             |
| `right color`     | color       |          | Alias for `r color`.                                                                                                                       |
| `size`            | length      |          | Alias for [`qrcode`'s][qrcode] `height` option.                                                                                            |
| `tight`           | flag        |          | [`qrcode`][qrcode] option adding no additional space around the qr-code.                                                                   |
| `version`         | [0..40] ∈ ℕ |   `0`    | [`qrcode`][qrcode] option affecting the size (tries to be as small as possible).                                                           |
| `width`           | length      |          | Alias for [`qrcode`'s][qrcode] `height` option.                                                                                            |

The defaults are set like this:

```LateX
\fancyqrset{image padding=0,gradient=true,gradient angle=135,r color=teal,l color=purple}
```

[^1]: The package will automatically calculate the required `\FancyQrDoNotPrintSquare` (you have to ensure that the qr-code still has enough information to be readable). Therefore, the image will not scale with the qr-code.

[qrcode]: https://www.ctan.org/pkg/qrcode
