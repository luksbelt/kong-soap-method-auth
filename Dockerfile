FROM abaez/luarocks:openresty

COPY / /rock/
RUN apk update && apk add expat-dev && apk add zip
RUN cd rock && ls && luarocks make

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]