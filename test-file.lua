local fkey = require("lua-filekey")

local key1 = fkey.new("o1.txt")

local key2 = fkey.new("o2.txt")

print("key 1 (o1.txt) == key 2 (o2.txt) ?", key1 == key2)

local key3 = fkey.new("o1.txt")
print("key 1 (o1.txt) == key 3 (o1.txt) ?", key1 == key3)
