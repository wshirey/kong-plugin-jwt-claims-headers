local BasePlugin = require "kong.plugins.base_plugin"
local responses = require "kong.tools.responses"
local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local req_set_header = ngx.req.set_header
local ngx_re_gmatch = ngx.re.gmatch

local JwtClaimsHeadersHandler = BasePlugin:extend()

local function retrieve_token(request, conf)
  local uri_parameters = request.get_uri_args()

  for _, v in ipairs(conf.uri_param_names) do
    if uri_parameters[v] then
      return uri_parameters[v]
    end
  end

  local authorization_header = request.get_headers()["authorization"]
  if authorization_header then
    local iterator, iter_err = ngx_re_gmatch(authorization_header, "\\s*[Bb]earer\\s+(.+)")
    if not iterator then
      return nil, iter_err
    end

    local m, err = iterator()
    if err then
      return nil, err
    end

    if m and #m > 0 then
      return m[1]
    end
  end
end

function JwtClaimsHeadersHandler:new()
  JwtClaimsHeadersHandler.super.new(self, "jwt-claims-headers")
end

function JwtClaimsHeadersHandler:access(conf)
  JwtClaimsHeadersHandler.super.access(self)
  local continue_on_error = conf.continue_on_error

  local token, err = retrieve_token(ngx.req, conf)
  if err and not continue_on_error then
    return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
  end

  if not token and not continue_on_error then
    return responses.send_HTTP_UNAUTHORIZED()
  elseif not token and continue_on_error then
    return
  end

  local jwt, err = jwt_decoder:new(token)
  if err and not continue_on_error then
    return responses.send_HTTP_INTERNAL_SERVER_ERROR()
  end

  local claims = jwt.claims
  for claim_key,claim_value in pairs(claims) do
    for _,claim_pattern in pairs(conf.claims_to_include) do      
      if string.match(claim_key, "^"..claim_pattern.."$") then
        req_set_header("X-"..claim_key, claim_value)
      end
    end
  end
end

return JwtClaimsHeadersHandler
