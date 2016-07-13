
# kong-plugin-jwt-claims-headers

Add unencrypted, base64-decoded claims from a JWT payload as request headers to
the upstream service.

## How it works

When enabled, this plugin will add new headers to requests based on the claims 
in the JWT provided in the request. The generated headers follow the naming 
convention of `x-<claim-name>`. For example, if the JWT payload object is

```json
{
  "sub"   : "1234567890",
  "name"  : "John Doe",
  "admin" : true
}
```

then the following headers would be added

```
x-sub   : "1234567890"
x-name  : "John Doe"
x-admin : true
```

## Configuration

Similar to the built-in JWT Kong plugin, you can associate the jwt-claims-headers
plugin with an api with the following request

```bash
curl -X POST http://localhost:8001/apis/29414666-6b91-430a-9ff0-50d691b03a45/plugins \
  --data "name=jwt-claims-headers" \
  --data "config.uri_param_names=jwt" \
  --data "config.claims_to_include=.*" \
  --data "config.continue_on_error=true"
```

form parameter|required|description
---|---|---
`name`|*required*|The name of the plugin to use, in this case: `jwt-claims-headers`
`uri_param_names`|*optional*|A list of querystring parameters that Kong will inspect to retrieve JWTs. Defaults to `jwt`.
`claims_to_include`|*required*|A list of claims that Kong will expose in request headers. Lua pattern expressions are valid, e.g., `kong-.*` will include `kong-id`, `kong-email`, etc. Defaults to `.*` (include all claims). 
`continue_on_error`|*required*|Whether to send the request to the upstream service if a failure occurs (no JWT token present, error decoding, etc). Defaults to `true`.

