FROM alpine:3.11
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && apk add  gcc g++ libc-dev  wget vim  openssl-dev make  linux-headers

COPY ./redis-5.0.7.tar.gz redis-5.0.7.tar.gz

#通过选择更小的镜像，删除不必要文件清理不必要的安装缓存，从而瘦身镜像
#创建相关目录能够看到日志信息跟数据跟配置文件
RUN mkdir -p /usr/src/redis \
    && mkdir -p /redis/data \
    && mkdir -p /redis/conf \
    && mkdir -p /redis/log   \
    && mkdir -p /var/log/redis \
    && tar -zxvf redis-5.0.7.tar.gz -C /usr/src/redis \
    && cd /usr/src/redis/redis-5.0.7 && make \
    && cd /usr/src/redis/redis-5.0.7 && make install \
    && rm -rf redis-5.0.7.tar.gz

RUN apk del gcc g++ libc-dev  openssl-dev make  linux-headers
# 做 redisbloom的使用 要有make

COPY ./conf/redis.conf /redis/conf/redis.conf

EXPOSE 6379
