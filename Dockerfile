# A docker file that works with Spark on Kubernetes
FROM jamesrcounts/spark:2.3.0 AS base
WORKDIR /opt/ml

FROM maven AS build-env

WORKDIR /opt/input

COPY ../pom.xml ./
RUN mvn dependency:resolve

# Copy rest of application
COPY .. ./
RUN mvn clean install

FROM base AS final
RUN mkdir -p /opt/spark/jars
COPY --from=build-env /opt/input/target/variant-spark_2.11-0.2.0-SNAPSHOT-all.jar  /opt/spark/jars