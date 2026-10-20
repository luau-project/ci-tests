local ssl = require("ssl")

local ctx = ssl.newcontext({ protocol = "tlsv1_2", mode = "peer"})

assert(ctx, "Failed to create context")

print("context was created successfully.")
