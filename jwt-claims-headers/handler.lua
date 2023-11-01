local sub = string.sub
local pairs = pairs

local jwt_decoder = require "kong.plugins.jwt.jwt_parser"

local JwtClaimsHeadersHandler = {
    PRIORITY = 900,
    VERSION = "1.0"
}

local function retrieve_token(request, conf)
  local uri_parameters = request.get_uri_args()

  for _, v in pairs(conf.uri_param_names) do
    if uri_parameters[v] then
      return uri_parameters[v]
    end
  end

  local authorization_header = request.get_headers()['authorization']
  if authorization_header then
    local found = string.match(authorization_header, "\\s+[Bb]earer\\s+(.+)")

    if found then
      return found
    end
    return nil
  end
end

function JwtClaimsHeadersHandler:access(conf)
    local claims = nil
    local header = nil

    local token, err = retrieve_token(kong.request, conf)
    if err and not conf.continue_on_error then
      return kong.response.exit(500, { message = err })
    end

    if not token and not conf.continue_on_error then
      return kong.response.exit(401)
    elseif not token and conf.continue_on_error then
      return
    end

    local jwt, err = jwt_decoder:new((sub(kong.request.get_header("Authorization"), 8)))
    if err and not conf.continue_on_error then
      return kong.response.exit(500, { message = err })
    end

    claims = jwt.claims
    header = jwt.header

    for claim_key, claim_value in pairs(claims) do
      for _, claim_pattern in pairs(conf.claims_to_include) do
        if string.match(claim_key, "^"..claim_pattern.."$") then
          kong.service.request.set_header("X-"..claim_key, claim_value)
        end
      end
    end
end

return JwtClaimsHeadersHandler
