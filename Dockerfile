ARG FIVEM_NUM=3961
ARG FIVEM_VER=3961-dbbc281c3d416a3cd7881ff140507ca39300d3a4
ARG DATA_VER=dd38bd01923a0595ecccef8026f1310304d7b0e3
FROM alpine:latest as builder
ARG FIVEM_VER
ARG DATA_VER

WORKDIR /output
USER root
RUN wget -O- http://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${FIVEM_VER}/fx.tar.xz \
        | tar xJ --strip-components=1 \
            --exclude alpine/dev --exclude alpine/proc \
            --exclude alpine/run --exclude alpine/sys \
 && mkdir -p /output/opt/cfx-server-data \
#  && wget -O- http://github.com/citizenfx/cfx-server-data/archive/${DATA_VER}.tar.gz \
#         | tar xz --strip-components=1 -C opt/cfx-server-data \
#     \
 && apk -p $PWD add tini mariadb-dev tzdata

RUN apk add --no-cache git

RUN git clone https://github.com/citizenfx/cfx-server-data.git /output/opt/cfx-server-data


ADD entrypoint usr/bin/entrypoint
RUN chmod +x /output/usr/bin/entrypoint

#================

FROM scratch

ARG FIVEM_VER
ARG FIVEM_NUM
ARG DATA_VER

LABEL org.label-schema.name="FiveM" \
      org.label-schema.url="https://fivem.net" \
      org.label-schema.description="FiveM is a modification for Grand Theft Auto V enabling you to play multiplayer on customized dedicated servers." \
      org.label-schema.version=${FIVEM_NUM}

COPY --from=builder /output/ /

WORKDIR /config

EXPOSE 30120

# Default to an empty CMD, so we can use it to add seperate args to the binary
CMD [""]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/entrypoint"]
