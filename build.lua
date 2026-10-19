#!/usr/bin/env texlua

-- Execute with ======================================================
-- l3build tag
-- l3build ctan
-- l3build upload
-- l3build clean
-- Settings ==========================================================
bundle = ""
module = "fancyqr"
ctanpkg = module
-- TMPDIR is unset (or empty) on the CI runners, and `l3build check` has to put
-- its output somewhere the workflow can pick it up from
builddir = os.getenv("TMPDIR")
if not builddir or builddir == "" then builddir = "build" end

-- Package date ======================================================
packagedate = os.date("!%Y-%m-%d")

-- interacting with git ==============================================
function git(...)
    local args = {...}
    table.insert(args, 1, 'git')
    local cmd = table.concat(args, ' ')
    print('Executing:', cmd)
    os.execute(cmd)
end

-- replace version tags in .sty and -doc.tex files ===================
tagfiles = {"*.sty", "*-doc.tex"}
function update_tag(file, content, tagname, tagdate)
    tagdate = string.gsub(packagedate, "-", "/")
    if string.match(file, "%.sty$") then
        content = string.gsub(content, "\\ProvidesPackage{(.-)}%[%d%d%d%d%/%d%d%/%d%d version v%d%.%d+",
            "\\ProvidesPackage{%1}[" .. tagdate .. " version " .. tagname)
        return content
    elseif string.match(file, "%-doc%.tex$") then
        -- the version sits in the title block, not in \date
        content = string.gsub(content, "Version v%d%.%d+ \\textendash{} %d%d%d%d%/%d%d%/%d%d",
            "Version " .. tagname .. " \\textendash{} " .. tagdate)
        -- and the entry of the version history
        content = string.gsub(content, "\\ForVersion{" .. string.gsub(tagname, "^v", "") .. "}{unreleased}",
            "\\ForVersion{" .. string.gsub(tagname, "^v", "") .. "}{" .. packagedate .. "}")
        return content
    end
    return content
end

-- committing retagged file and tag the commit =======================
-- only the maintainer's checkout has it (it holds the upload token); `check`
-- must still run on CI, where the file is absent
if fileexists("build-private.lua") then
    require('build-private.lua')
end

function tag_hook(tagname)
    -- fail if tagname is missing
    if not tagname then
        print("No tagname provided, please use 'l3build tag <tagname>'")
        return
    end
    -- fail if tag already exists locally
    if os.execute("git rev-parse " .. tagname) == 0 then
        print("Tag '" .. tagname .. "' already exists locally")
        return
    end
    -- update the tag first
    for _, file in ipairs(tagfiles) do
        for _, file in ipairs(filelist(file)) do
            local content = update_tag(file, readfile(file), tagname)
            writefile(file, content)
        end
    end
    -- the heading of the hand-written changelog entry
    local log = readfile("CHANGELOG.md")
    log = string.gsub(log, "## " .. tagname .. " %(unreleased%)",
        "## [" .. tagname .. "](https://github.com/EagleoutIce/" .. module .. "/tree/" .. tagname .. ") (" .. packagedate .. ")")
    writefile("CHANGELOG.md", log)
    git("add", "*.sty")
    git("add", "*-doc.tex")
    -- the changelog is generated only with the token of build-private.lua
    if token then
        os.execute("github_changelog_generator --user EagleoutIce --future-release \"" .. tagname .. "\" --project \"" .. module .. "\" --token \"" .. token .. "\"")
    end
    git("add", "CHANGELOG.md")
    git("status")
    -- ask for verification if the tag is correct and all is updated correctly
    print("Please verify the changes and commit the changes with the tag '" .. tagname .. "'")
    print("Press any key to continue...")
    io.read()
    
    git("commit -S -m 'step version " .. tagname .. "'")
    git("tag", tagname)
    git("push", "--tags")
    git("push")
end

-- collecting files for ctan =========================================
typesetfiles = { module .. "-doc.tex" }
-- the manual externalizes its codes, see the key externalize
typesetopts = "-interaction=nonstopmode -shell-escape"
docfiles = { module .. "-doc.ist", "qr-example.tex", "qr-minimal.tex" }
indexstyle = module .. "-doc.ist"
-- the manual highlights its listings with xlistings (a git submodule)
function docinit_hook()
    cp("xlistings.sty", "xlistings", typesetdir)
    cp("code-link.sty", "xlistings", typesetdir)
    cp("*.cfg", "xlistings/langs", typesetdir)
    return 0
end

textfiles = {"README.md", "LICENSE", "CHANGELOG.md"}
ctanreadme = "README.md"

-- the package is the .sty and its style files; the manual's source ships with
-- the sources
installfiles = {"*.sty", "*.code"}
sourcefiles = {"*.sty", "*.code", module .. "-doc.tex"}
unpackfiles = {}

-- Release a TDS-style zip
packtdszip = false

-- Preserve structure for CTAN
flatten = true

-- uploading to ctan (l3build upload <version>) =======================
uploadconfig = {
    pkg          = ctanpkg,
    author       = "Florian Sihler",
    uploader     = "Florian Sihler",
    email        = "florian.sihler@uni-ulm.de",
    license      = "lppl1.3c",
    summary      = "Fancy QR-Codes with the qrcode package",
    ctanPath     = "/macros/latex/contrib/" .. ctanpkg,
    repository   = "https://github.com/EagleoutIce/" .. ctanpkg,
    bugtracker   = "https://github.com/EagleoutIce/" .. ctanpkg .. "/issues",
    support      = "https://github.com/EagleoutIce/" .. ctanpkg .. "/issues",
    announcement = "Version 2.5 adds the styles halloween, snow, castle and christmas "
        .. "with figures and decorations, mixes decorations of one style into another "
        .. "(add=), places figures by hand, keeps each code in a file for faster later "
        .. "runs and draws whole-code backgrounds. See CHANGELOG.md for all changes.",
    note         = "Built with l3build; the manual needs the xlistings package from "
        .. "https://github.com/EagleoutIce/xlistings to be rebuilt.",
    update       = true,
}

-- tests =============================================================
-- fancyqr.sty and the fancyqr-style-*.code files are part of `installfiles`,
-- so every check runs against the copies from this repository and not against
-- whatever is installed in the TeX tree
testfiledir    = "tests"
supportdir     = testfiledir .. "/support"
checksuppfiles = {"*.sty"}
checkengines   = {"pdftex"}
stdengine      = "pdftex"
checkformat    = "latex"
-- text beyond ASCII is handled differently by every engine
checkconfigs   = {"build", "config-unicode"}

-- cleanup ===========================================================
cleanfiles = { module .. "-ctan.curlopt", module .. "-ctan.zip"}

-- scanning ==========================================================
-- `l3build scan` draws random codes over all styles and scans them with zxing
-- and ZBar, see tests/scan/scancheck.py; SCAN_COUNT, SCAN_DPI (e.g. "100 300")
-- and SCAN_STYLES narrow it, or names as in `l3build scan 100 castle 150dpi`;
-- SCAN_PYTHON picks the interpreter that has zxing-cpp
target_list = target_list or {}
target_list.scan = {
    desc = "Scans random codes of every style with zxing and ZBar",
    func = function()
        local function opt(name, flag)
            local v = os.getenv(name)
            return (v and v ~= "") and (" " .. flag .. " " .. v) or ""
        end
        -- names on the command line: a number is the count, NNNdpi a resolution,
        -- anything else a style, as in `l3build scan 100 castle 150dpi`
        local count, dpis, styles = nil, {}, {}
        for _, n in ipairs(options["names"] or {}) do
            if n:match("^%d+$") then count = n
            elseif n:match("^%d+dpi$") then dpis[#dpis + 1] = n:gsub("dpi$", "")
            else styles[#styles + 1] = n end
        end
        local cmd = (os.getenv("SCAN_PYTHON") or "python3") .. " tests/scan/scancheck.py"
            .. (count and (" --count " .. count) or opt("SCAN_COUNT", "--count"))
            .. (#dpis > 0 and (" --dpi " .. table.concat(dpis, " ")) or opt("SCAN_DPI", "--dpi"))
            .. (#styles > 0 and (" --styles " .. table.concat(styles, " ")) or opt("SCAN_STYLES", "--styles"))
        print("Executing: " .. cmd)
        local ok, _, code = os.execute(cmd)
        return (ok == true or ok == 0) and 0 or (code or 1)
    end
}
