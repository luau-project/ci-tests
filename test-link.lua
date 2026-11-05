local fkey = require("lua-filekey")

local is_windows = package.config:sub(1, 1) == "\\"

local function create_link(target, link)
    local res = false
    local cmd = is_windows
        and ("if exist %q del %q && mklink %q %q"):format(link, link, link, target)
        or  ("ln -sf %q %q"):format(target, link)
    local process = io.popen(cmd)
    if process then
        local output = process:read("*a")
        process:close()
        res = true
    end
    return res
end

local key1 = fkey.new("o1.txt")

if not create_link("o1.txt", "o.txt") then
    error("Failed to create a symlink")
end

local key2 = fkey.new("o.txt", true)

print("key 1 (o1.txt) == key 2 (o.txt not following symlink to o1.txt)?", key1 == key2)

local key3 = fkey.new("o.txt", false)

print("key 1 (o1.txt) == key 3 (o.txt following symlink to o1.txt)?", key1 == key3)
