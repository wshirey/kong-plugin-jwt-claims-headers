local typedefs = require "kong.db.schema.typedefs"

return {
    name = "jwt-claims-headers",
    fields = {
      { route = typedefs.no_route },
      { service = typedefs.no_service },
      { consumer = typedefs.no_consumer },
      { protocols = typedefs.protocols_http },
      { config = {
          type = "record",
          fields = {
            { uri_param_names = {
                type = "array",
                elements = {
                  type = "string",
                },
                default = {"jwt"},
            }, },
            { claims_to_include = {
                type = "array",
                elements = {
                  type = "string",
                },
                default = {".*"},
            }, },
            { continue_on_error = {
                type = "boolean",
                default = true,
            }, }, 
          }
        }
      }
    }
}
