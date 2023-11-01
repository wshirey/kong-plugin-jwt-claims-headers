# Deploy: 
```
kubectl create configmap kong-plugin-mp-test --from-file=jwt-claims-headers -n kong-nlb -oyaml --dry-run=client | kubectl apply -f-
```
:'( - automate this??


## Origins

A mashup of
* https://github.com/wshirey/kong-plugin-jwt-claims-headers
* https://github.com/yesinteractive/kong-jwt2header