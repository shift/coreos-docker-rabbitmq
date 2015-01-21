FROM shift/coreos-ubuntu-sensuplugins
MAINTAINER Vincent Palmer <shift+gh@someone.section.me>

# Install RabbitMQ
RUN \
  apt-get install wget && \
  wget -qO - https://www.rabbitmq.com/rabbitmq-signing-key-public.asc | apt-key add - && \
  echo "deb http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y rabbitmq-server && \
  rm -rf /var/lib/apt/lists/* && \
  cd /usr/lib/rabbitmq/lib/rabbitmq_server-*/plugins/ && \
  wget http://www.rabbitmq.com/community-plugins/v3.4.x/rabbitmq_auth_backend_http-3.4.x-76c3a3c2.ez && \
  cd - && \
  rabbitmq-plugins enable --offline rabbitmq_management rabbitmq_web_stomp rabbitmq_auth_backend_http && \
  echo "[{rabbit, [{auth_backends, [rabbit_auth_backend_http, rabbit_auth_backend_internal]}]},{rabbitmq_auth_backend_http,[{user_path, "http://$RABBITMQ_AUTH_SERVER/auth/user"},{vhost_path, "http://$RABBITMQ_AUTH_SERVER/auth/vhost"},{resource_path, "http://$RABBITMQ_AUTH_SERVER/auth/resource"}]}]." > /etc/rabbitmq/rabbitmq.config && \
  rm -rf /var/lib/apt/lists/*

ENV RABBITMQ_LOG_BASE /data/log
ENV RABBITMQ_MNESIA_BASE /data/mnesia

VOLUME ["/data/log", "/data/mnesia"]
ADD files/supervisord.conf /etc/supervisor/conf.d/rabbitmq.conf
EXPOSE 5672 15672 15674
CMD ["/usr/bin/supervisord"]
