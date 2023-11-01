# Deploy: 

Deploy to kong nodes:
```
kubectl create configmap kong-plugin-jwt-claims-headers --from-file=jwt-claims-headers -n kong -oyaml --dry-run=client | kubectl apply -f-
```
:'( - automate this??

Deploy schema to konnect:
```
curl -H "Authorization: ${TF_VAR_kong_admin_token}"  https://us.api.konghq.com/v2/control-planes/${GATEWAY_ID}/core-entities/plugin-schemas/jwt-claims-headers --header 'Content-Type: application/json' -XPUT --data "{\"lua_schema\": $(jq -Rs '.' < jwt-claims-headers/schema.lua)}"
```


## Origins

A mashup of
* https://github.com/wshirey/kong-plugin-jwt-claims-headers
* https://github.com/yesinteractive/kong-jwt2header
