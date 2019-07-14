# Kong Soap Method Auth
## Overview

This plugin will verify if the authenticated consumer was added in the white list for the requested soap-method.

## How this plugin works

This plugin:
- Validate that there is an autenticated consumer.
- Parses the xml request message to detect the soap method name.
- Validates if the consumer is presente in the "consumer_method" list with the current method name.

## Dependencies
- Expat https://libexpat.github.io/
- luaxpath https://luarocks.org/modules/basiliscos/luaxpath


## Package rock whit Docker
```
docker build -t kong-soap-method-auth .
docker run --rm -v $PWD/output:/rock kong-soap-method-auth
```

## Package rock with luarocks
```
$ git clone https://github.com/luksbelt/kong-soap-method-auth.git /path/to/kong/plugins/kong-soap-method-auth
$ cd /path/to/kong/plugins/kong-soap-method-auth
$ luarocks make *.rockspec
```

## Installation
```
$ luarocks install kong-soap-method-auth
```

## Schema

custom_id:[method_name;]

Example:
custom_id:method1;method2;


## How To Use
The following is an example of how to enable a consumer to use a method
```
$ curl -XPOST localhost:8001/services/{service}/plugins \
    --data "name=soap-method-auth" \
    --data "config.consumer_method=lucasb:method1;method2"
```