package = "lua-filekey-refs"
version = "dev-1"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   homepage = "https://github.com/lunarmodules/luafilesystem",
   license = "MIT"
}
dependencies = {
    "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      ["lua-filekey"] = {
         sources = "lua-filekey.c",
         defines = { "HAVE_REFS" }
      }
   }
}
