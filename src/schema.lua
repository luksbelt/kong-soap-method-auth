local typedefs = require "kong.db.schema.typedefs"



local colon_string_array = {
  type = "array",
  default = {},
  elements = { type = "string", match = "^[^:]+:[%w+;]*%w*$" },
}


return {
  name = "soap-method-auth",
  fields = {
    { run_on = typedefs.run_on_first },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { consumer_method = colon_string_array, },
        },
      },
    },
  },
}
