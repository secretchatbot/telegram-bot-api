FROM centos:7 as builder
RUN yum update -y && \
    yum install -y centos-release-scl-rh epel-release && \
    yum install -y devtoolset-9-gcc devtoolset-9-gcc-c++ && \
    yum install -y gcc-c++ make git zlib-devel openssl-devel gperf cmake3

WORKDIR /root
RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git && \
    mkdir -p telegram-bot-api/build

WORKDIR /root/telegram-bot-api/build
RUN CC=/opt/rh/devtoolset-9/root/usr/bin/gcc CXX=/opt/rh/devtoolset-9/root/usr/bin/g++ cmake3 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. && \
    cmake3 --build . --target install -j 3

FROM centos:7
RUN yum update -y && \
    yum install -y gcc-c++ make git zlib-devel openssl-devel gperf cmake3 && \
    yum clean all && \
    rm -rf /var/cache/yum

COPY --from=builder /root/telegram-bot-api/build /opt/telegram-bot-api
RUN ln -s /opt/telegram-bot-api/telegram-bot-api /usr/bin/telegram-bot-api

CMD ["sh", "-c", "telegram-bot-api", "--api-id=$TELEGRAM_API_ID", "--api-hash=$TELEGRAM_API_HASH", "--http-port=8081", "--dir=/var/lib/telegram-bot-api", "--temp-dir=/tmp/telegram-bot-api", "--username=telegram-bot-api", "--groupname=telegram-bot-api", "--max-webhook-connections=60000", "--local"]
