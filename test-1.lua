
local context = require("ssl.context")

local ctx, msg = context.create("tlsv1_2")

assert(ctx, msg)

local success

success, msg = context.loadoscerts(ctx)

assert(success, msg)

print("os certificates were loaded!")
