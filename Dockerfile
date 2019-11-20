FROM openjdk:8-alpine as builder
  
RUN apk update && apk add git alpine-sdk openssl-dev zlib-dev gperf cmake linux-headers

WORKDIR /tmp/_build_tdlib
RUN git clone https://github.com/tdlib/td.git .
RUN git checkout 818279238c9fd3daa839f8232e6948c93da7fe51

WORKDIR /tmp/_build_tdlib/jnibuild
RUN cmake -DCMAKE_BUILD_TYPE=Release -DTD_ENABLE_JNI=ON -DCMAKE_INSTALL_PREFIX:PATH=../example/java/td ..
RUN cmake --build . --target install

WORKDIR /tmp/_build_tdlib/example/java/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DTd_DIR=/tmp/_build_tdlib/example/java/td/lib/cmake/Td -DCMAKE_INSTALL_PREFIX:PATH=.. ..
RUN cmake --build . --target install

WORKDIR /usr/local/lib/tdlib
RUN cp -r /tmp/_build_tdlib/example/java/docs .
RUN cp -r /tmp/_build_tdlib/example/java/bin .

RUN ls -lh /usr/local/lib/tdlib

RUN rm -rf /tmp/_build_tdlib/


FROM openjdk:8-alpine

RUN apk update && apk add openssl zlib

COPY --from=builder /usr/local/lib/tdlib /usr/local/lib/tdlib
