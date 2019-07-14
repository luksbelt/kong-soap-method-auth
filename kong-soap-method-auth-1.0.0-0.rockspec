package = "kong-soap-method-auth"
version = "1.0.0-0"
supported_platforms = {"linux", "macosx"}
source = {
  url = "git@github.com:luksbelt/kong-soap-method-auth.git",
  tag = "1.0.0"
}
description = {
  summary = "Kong Plugin for soap method authorization",
  license = "Apache-2.0",
}
dependencies = {
  "lua >= 5.1",
  "luaxpath == 1.2-4",
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.soap-method-auth.handler"] = "src/handler.lua",
    ["kong.plugins.soap-method-auth.schema"] = "src/schema.lua",
  }
}