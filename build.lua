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
    elseif string.match(file, "*-doc.tex$") then
        content = string.gsub(content, "\\date{Version v%d%.%d+ \\textendash\\ %d%d%d%d%/%d%d%/%d%d",
            "\\date{Version " .. tagname .. " \\textendash{} " .. tagdate)
        return content
    end
    return content
end

-- committing retagged file and tag the commit =======================
require('build-private.lua')

function tag_hook(tagname)
    -- update the tag first
    for _, file in ipairs(tagfiles) do
        for _, file in ipairs(filelist(file)) do
            local content = update_tag(file, readfile(file), tagname)
            writefile(file, content)
        end
    end
    git("add", "*.sty")
    git("add", "*-doc.tex")
    os.execute("github_changelog_generator --user EagleoutIce --future-release \"" .. tagname .. "\" --project \"" .. module .. "\" --token \"" .. token .. "\"")
    git("add", "CHANGELOG.md")
    git("status")
    -- ask for verification if the tag is correct and all is updated correctly
    print("Please verify the changes and commit the changes with the tag '" .. tagname .. "'")
    print("Press any key to continue...")
    io.read()
    
    git("commit -m 'step version " .. tagname .. "'")
    git("tag", tagname)
    git("push", "--tags")
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

-- cleanup ===========================================================
cleanfiles = { module .. "-ctan.curlopt", module .. "-ctan.zip"}
