# tikz-qr

[![compile qr](https://github.com/EagleoutIce/tikz-qr/actions/workflows/compile.yaml/badge.svg)](https://github.com/EagleoutIce/tikz-qr/actions/workflows/compile.yaml)

[<img src="https://github.com/EagleoutIce/tikz-qr/blob/gh-pages/preview-1.png?raw=true" width="600"/>](qr.tex)

Simple package to create fancy qr codes with the help of the [`qrcode`](https://www.ctan.org/pkg/qrcode)-package.
You may use `\fancyqr` just like the normal `\qrcode` (`\fancyqr[<qr-options>]{<url>}`).

If you do want to hide a center square (e.g, because you want to embed an image) you can use `\FancyQrDoNotPrintSquare{<x>}{<y>}` to hide a rectangle with radius x and y set from the center. If you choose this option, the default `\FancyQrRoundCut` that rounds cut corners can be changed with `\FancyQrHardCut`.
At the moment, there are six other styles `flat`, `frame`, `blob`, `glitch`, `swift`, and `dots`, that you can load (locally) by using `\FancyQrLoad{<name>}`. The default style is named `default` and can be 'reset' by `\FancyQrLoad{default}` or `\FancyLoadDefault`.

There are the following extra qr-options (you can set all of them with `\fancyqrset{<keys>}`):
| Option            | Type    | Default  | Explanation                                                |
| ----------------- | ------- | :------: | ---------------------------------------------------------- |
| `image`           | LaTeX   |          | Automatically canter an image.[^1]                         |
| `image padding`   | number  |          | Additionally hide blocks (x & y) around the image.         |
| `image x padding` | number  |   `0`    | Additionally hide blocks (x) around the image.             |
| `image y padding` | number  |   `0`    | Additionally hide blocks (y) around the image.             |
| `gradient`        | boolean |   true   | Toggle the color gradient                                  |
| `color`           | color   |          | Disables the `gradient` and sets the qr color accordingly. |
| `l color`         | color   | `purple` | Set the top left gradient color.                           |
| `left color`      | color   |          | Alias for `l color`.                                       |
| `r color`         | color   |  `teal`  | Set the bottom right gradient color.                       |
| `right color`     | color   |          | Alias for `r color`.                                       |
| `gradient angle`  | angle   |  `135`   | Change the gradient angle.                                 |

The defaults are set like this:

```LateX
\fancyqrset{image padding=0,gradient=true,gradient angle=135,r color=teal,l color=purple}
```

[^1]: The package will automatically calculate the required `\FancyQrDoNotPrintSquare` (you have to make sure the, the qr code still has enough information to readable). Therefore, the image will not scale with the qr code.
