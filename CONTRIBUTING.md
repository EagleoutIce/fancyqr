# Thank you for every contribution

Just select and or create an issue, work on that in your own fork and open a pull-request!

If you have any questions, just send me a mail at: <florian.sihler@uni-ulm.de>.

## Checks

- `l3build check` runs the regression tests.
- `l3build scan` draws 1000 codes over all styles with random texts, seeds and sizes, scans each at 100, 150 and 300 dpi with zxing and ZBar, and lists every code that does not scan (it fails if one does not). It needs `pdftoppm`, `zbarimg` and the Python packages `zxing-cpp` and `Pillow`. Narrow it down with the environment variables `SCAN_COUNT`, `SCAN_DPI` (e.g. `"100 300"`) and `SCAN_STYLES` (e.g. `"castle christmas"`), and pick the Python with `SCAN_PYTHON`, as in `SCAN_COUNT=100 SCAN_STYLES=castle l3build scan`. It calls `tests/scan/scancheck.py`, which also takes `--keep <dir>` to save the failing renders.
