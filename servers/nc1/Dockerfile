FROM nextcloud
ENV HOST=nc1
ENV DBHOST=maria1.docker
ENV USER=dawid
ENV PASS=relativity
RUN ln -s /tls/$HOST.crt /tls/server.cert
RUN ln -s /tls/$HOST.key /tls/server.key
