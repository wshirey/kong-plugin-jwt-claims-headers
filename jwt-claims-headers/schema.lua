return {
    name = "jwt-claims-headers",
    fields = {
      { route = {
        type = "foreign",
        reference = "routes",
        eq = null,
      } },
      { config = {
          type = "record",
          fields = {
            { uri_param_names = {
                type = "set",
                elements = { type = "string" },
                default = {"jwt"},
            }, },
            { header_names = {
                type = "set",
                elements = { type = "string" },
                default = { "authorization" },
            }, },
            { cookie_names = {
              type = "set",
              elements = { type = "string" },
              default = {"jwt"},
            }, },
            { claims_to_include = {
                type = "set",
                elements = { type = "string" },
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
