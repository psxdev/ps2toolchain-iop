# First stage of Dockerfile
FROM alpine:latest

ENV PS2DEV /usr/local/ps2dev
ENV PATH $PATH:${PS2DEV}/iop/bin

COPY . /src

RUN apk add build-base bash wget gcc git make flex bison gettext texinfo gmp-dev mpfr-dev mpc1-dev
RUN cd /src && ./toolchain.sh

# Second stage of Dockerfile
FROM alpine:latest  

ENV PS2DEV /usr/local/ps2dev
ENV PATH $PATH:${PS2DEV}/iop/bin

COPY --from=0 ${PS2DEV} ${PS2DEV}
