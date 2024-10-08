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
builddir = os.getenv("TMPDIR")

-- Package version ===================================================
packageversion = "v2.1"
-- packageversion="v1.3"

-- Package date ======================================================
packagedate = os.date("!%Y-%m-%d")
-- packagedate = "2020-01-02"

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
            "\\ProvidesPackage{%1}[" .. tagdate .. " version " .. packageversion)
        return content
    elseif string.match(file, "*-doc.tex$") then
        content = string.gsub(content, "\\date{Version v%d%.%d+ \\textendash\\ %d%d%d%d%/%d%d%/%d%d",
            "\\date{Version " .. packageversion .. " \\textendash{} " .. tagdate)
        return content
    end
    return content
end

-- committing retagged file and tag the commit =======================
require('build-private.lua')

function tag_hook(tagname)
    git("add", "*.sty")
    git("add", "*-doc.tex")
    git("commit -m 'step version " .. packageversion .. "'")
    git("tag", packageversion)
    git("push", "--tags")
    os.execute("github_changelog_generator --user EagleoutIce --project \"" .. module .. "\" --token \"" .. token .. "\"")
    git("add", "CHANGELOG.md")
    git("commit -m 'update changelog " .. packageversion .. "'")
    git("push")
end

-- collecting files for ctan =========================================
typesetfiles = { module .. "-doc.tex" }

textfiles = {"README.md"}
ctanreadme = "README.md"

installfiles = {"*.sty", "*.tex", "*.code"}
sourcefiles = installfiles
unpackfiles = {}

-- Release a TDS-style zip
packtdszip = false

-- Preserve structure for CTAN
flatten = true

-- configuring ctan upload ===========================================
uploadconfig = {
    author = uploadconfig.author,
    uploader = uploadconfig.uploader,
    email = uploadconfig.email,
    pkg = ctanpkg,
    version = packageversion .. " " .. packagedate,
    license = "gpl3.0",
    summary = "Fancy QR-Codes in LaTeX",
    ctanPath = "/graphics/pgf/contrib/" .. ctanpkg,
    repository = "https://github.com/EagleoutIce/" .. module,
    home = "https://github.com/EagleoutIce/" .. module,
    note = [[Uploaded automatically by l3build...]],
    bugtracker = "https://github.com/EagleoutIce/" .. module .. "/issues",
    announcement_file = "announcement.txt"
}

-- cleanup ===========================================================
cleanfiles = { module .. "-ctan.curlopt", module .. "-ctan.zip"}
