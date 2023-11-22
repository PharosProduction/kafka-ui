ARG base_image

FROM $base_image

ARG vcs_url=unspecified
ARG vcs_branch=unspecified
ARG vcs_ref=unspecified

LABEL org.label-schema.name="kafka-ui" \
      org.label-schema.description="Kafka-UI" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.version="${scala_version}_${kafka_version}" \
      org.label-schema.vcs-url="${vcs_url}" \
      org.label-schema.schema-version="${vcs_branch}" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      maintainer="Pharos Production Inc."

ENV LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN apt-get update -y && apt-get install -y \
  bash \
  software-properties-common \
  nodejs

RUN groupadd -r kafkaui -g 1000 \
  && useradd -u 1000 -r -g kafkaui -s /sbin/nologin -c "Docker image user" kafkaui \
  && [ `id -u kafkaui` -eq 1000 ] \
  && [ `id -g kafkaui` -eq 1000 ]

WORKDIR /tmp

COPY . .

RUN mvn dependency:go-offline -Djava.net.preferIPv4Stack=true -Djavax.net.debug=ssl -Pprod -T 8C -Dparallel=all -DperCoreThreadCount=false -DthreadCount=8

RUN mvn install -Djava.net.preferIPv4Stack=true -Djavax.net.debug=ssl -Pprod -DskipTests -Dparallel=all -T 8C -DthreadCount=8

WORKDIR /etc/kafkaui

RUN mv /tmp/kafka-ui-api/target/kafka-ui-api-0.0.1-SNAPSHOT.jar /etc/kafkaui/kafka-ui.jar

RUN apt-get autoremove -y wget \
    curl \
  && apt-get clean \
  && rm -rf /tmp/* /var/lib/apt/lists/*

USER kafkaui

VOLUME ["/etc/kafkaui"]

EXPOSE 8080

CMD ["java", "-Dspring.config.additional-location=/etc/kafkaui/config.yaml", "--add-opens", "java.rmi/javax.rmi.ssl=ALL-UNNAMED", "-jar", "/etc/kafkaui/kafka-ui.jar"]
