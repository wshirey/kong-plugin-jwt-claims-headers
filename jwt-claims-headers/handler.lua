local sub = string.sub
local pairs = pairs

local jwt_decoder = require "kong.plugins.jwt.jwt_parser"

local JwtClaimsHeadersHandler = {
    PRIORITY = 805, -- JWT is 1450 so make sure we run after that verifies
    VERSION = "1.0"
}

local HEADER_PREFIX = "X-claim-"

local function retrieve_token(request, conf)
  local uri_parameters = request.get_query()

  -- URI param search
  for _, v in pairs(conf.uri_param_names) do
    if uri_parameters[v] then
      return uri_parameters[v]
    end
  end

  -- Header search
  local request_headers = request.get_headers()
  for _, v in pairs(conf.header_names) do
    local token_header = request_headers[v]
    if token_header then
      if type(token_header) == "table" then
        token_header = token_header[1]
      end
      local found = string.match(token_header, "[Bb]earer%s+(.+)")
      if found then
        return found
      end
    end
  end

  -- Cookie search
  for _, v in ipairs(conf.cookie_names) do
    local cookie = ngx.var["cookie_" .. v]
    if cookie and cookie ~= "" then
      return cookie
    end
  end

end

function JwtClaimsHeadersHandler:access(conf)
    local token, err = retrieve_token(kong.request, conf)
    if err and not conf.continue_on_error then
      return kong.response.exit(500, { message = err })
    end

    if not token and not conf.continue_on_error then
      return kong.response.exit(401, "Token not found")
    elseif not token and conf.continue_on_error then
      return
    end

    local jwt, err = jwt_decoder:new(token)
    if err then
      if conf.continue_on_error then
        return
      else
        return kong.response.exit(500, { message = err })
      end
    end

    local claims = jwt.claims

    for claim_key, claim_value in pairs(claims) do
      for _, claim_pattern in pairs(conf.claims_to_include) do
        if string.match(claim_key, "^"..claim_pattern.."$") then
          -- this only protects the add_header, if a used header isn't included in the claim then it could be passed by the user
          kong.service.request.clear_header(HEADER_PREFIX..claim_key)
          pcall(function ()
            if type(claim_value) == "table" then
              for _, claim_value_i in pairs(claim_value) do
                kong.service.request.add_header(HEADER_PREFIX..claim_key, claim_value_i)
              end
            else
              kong.service.request.set_header(HEADER_PREFIX..claim_key, claim_value)
            end
          end)
        end
      end
    end
end

return JwtClaimsHeadersHandler
