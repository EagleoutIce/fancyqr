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
    git("add", "*.sty")
    git("add", "*-doc.tex")
    os.execute("github_changelog_generator --user EagleoutIce --future-release \"" .. tagname .. "\" --project \"" .. module .. "\" --token \"" .. token .. "\"")
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

textfiles = {"README.md", "LICENSE"}
ctanreadme = "README.md"

installfiles = {"*.sty", "*.tex", "*.code"}
sourcefiles = installfiles
unpackfiles = {}

-- Release a TDS-style zip
packtdszip = false

-- Preserve structure for CTAN
flatten = true

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

-- cleanup ===========================================================
cleanfiles = { module .. "-ctan.curlopt", module .. "-ctan.zip"}
