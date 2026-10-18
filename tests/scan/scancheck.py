#!/usr/bin/env python3
"""Scan many fancyqr codes with zxing and ZBar and report the ones that fail.

Draws --count codes (default 1000) over all styles with random texts, seeds and
sizes from 4 to 5 cm (at 100 dpi at least about 3.5 pixels per module for the
longest texts), renders them at every --dpi and decodes each with zxing-cpp and zbarimg.
Needs lualatex (or --engine), pdftoppm, zbarimg and the Python packages
zxing-cpp and Pillow. Exits with 1 if a code fails in a decoder, so it can run
in CI:

    python3 tests/scan/scancheck.py --count 1000 --dpi 100 150 300
"""
import argparse, os, random, string, subprocess, sys, tempfile
from collections import Counter
from pathlib import Path

import zxingcpp
from PIL import Image

STYLES = ["default", "rounded", "flat", "frame", "dots", "blobs", "glitch", "goo",
          "glows", "halloween", "snow", "castle", "christmas"]
WORDS = ["fancy", "qr", "code", "castle", "ghost", "snow", "tree", "ulm", "tex", "ctan",
         "hello", "world", "pumpkin", "knight", "star", "river", "bench", "sledge"]
REPO = Path(__file__).resolve().parents[2]


def text(rng):
    kind = rng.randrange(4)
    if kind == 0:
        path = "/".join(rng.choice(WORDS) for _ in range(rng.randint(1, 4)))
        return f"https://example.org/{path}?id={rng.randint(0, 10**rng.randint(1, 12))}"
    if kind == 1:
        return " ".join(rng.choice(WORDS) for _ in range(rng.randint(1, 12)))
    if kind == 2:
        return "".join(rng.choice(string.digits) for _ in range(rng.randint(4, 80)))
    return "".join(rng.choice(string.ascii_letters + string.digits + "-.:/")
                   for _ in range(rng.randint(3, 120)))


def document(codes):
    lines = [r"\documentclass{article}", r"\usepackage[paperwidth=9cm,paperheight=9cm,margin=.5cm]{geometry}",
             r"\usepackage{fancyqr}", r"\pagestyle{empty}\fancyqrset{persist=false}", r"\begin{document}"]
    for style, seed, size, txt in codes:
        lines.append(rf"\begin{{center}}\vspace*{{\fill}}\fancyqr[style={style},seed={seed},size={size}cm,padding]{{{txt}}}"
                     r"\vspace*{\fill}\end{center}\newpage")
    lines.append(r"\end{document}")
    return "\n".join(lines)


def zbar(path):
    out = subprocess.run(["zbarimg", "-q", "--raw", str(path)], capture_output=True, text=True)
    return out.stdout.rstrip("\n").split("\n")[0] if out.returncode == 0 else None


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--count", type=int, default=1000)
    ap.add_argument("--dpi", type=int, nargs="+", default=[100, 150, 300])
    ap.add_argument("--styles", nargs="+", default=STYLES)
    ap.add_argument("--engine", default="lualatex")
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--keep", help="keep the renders of failing codes in this directory")
    ap.add_argument("--cores", type=int, default=4, help="CPU cores to use at most (default 4)")
    args = ap.parse_args()
    # stay gentle on the machine: a few cores at a low priority, for every subprocess too
    if hasattr(os, "sched_setaffinity"):
        cpus = sorted(os.sched_getaffinity(0))[:max(1, args.cores)]
        os.sched_setaffinity(0, cpus)
    os.environ.setdefault("OMP_NUM_THREADS", str(args.cores))
    os.nice(10)
    rng = random.Random(args.seed)
    codes = [(args.styles[i % len(args.styles)], rng.randint(1, 9999), rng.choice([4, 4.5, 5]), text(rng))
             for i in range(args.count)]
    fails, tried = Counter(), Counter()
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        (tmp / "codes.tex").write_text(document(codes))
        env = dict(os.environ, TEXINPUTS=f"{REPO}//:")
        run = subprocess.run([args.engine, "-interaction=nonstopmode", "codes.tex"], cwd=tmp, env=env,
                             capture_output=True, text=True)
        if run.returncode != 0 or not (tmp / "codes.pdf").exists():
            print("compiling failed:\n" + run.stdout[-3000:])
            return 2
        info = subprocess.run(["pdfinfo", "codes.pdf"], cwd=tmp, capture_output=True, text=True).stdout
        pages = int(next(l.split()[-1] for l in info.splitlines() if l.startswith("Pages:")))
        if pages != len(codes):
            print(f"expected {len(codes)} pages, got {pages}")
            return 2
        for dpi in args.dpi:
            subprocess.run(["pdftoppm", "-r", str(dpi), "-png", "codes.pdf", f"p{dpi}"], cwd=tmp, check=True)
            pages = sorted(tmp.glob(f"p{dpi}-*.png"), key=lambda p: int(p.stem.split("-")[1]))
            for (style, seed, size, txt), page in zip(codes, pages):
                found = {"zxing": [r.text for r in zxingcpp.read_barcodes(Image.open(page))], "zbar": [zbar(page)]}
                for decoder, texts in found.items():
                    tried[style, decoder] += 1
                    if txt not in texts:
                        fails[style, decoder] += 1
                        print(f"FAIL {decoder} {dpi}dpi {style} seed={seed} size={size}cm: {txt}")
                        if args.keep:
                            Path(args.keep).mkdir(parents=True, exist_ok=True)
                            page.replace(Path(args.keep) / f"{style}-{seed}-{dpi}-{decoder}.png")
    for style in args.styles:
        cells = ", ".join(f"{d} {fails[style, d]}/{tried[style, d]}" for d in ("zxing", "zbar"))
        print(f"{style:10} {cells}")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
