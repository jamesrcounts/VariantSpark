#!/bin/sh

set -e

function fatal_error () {
	echo "ERROR: $1" 1>&2
	exit 1
}

if [ -z ${MASTER+x} ];
    then
        echo "You must set the MASTER environment variable to a kubernetes API endpoint";
        echo "Example: https://ABC.sk1.us-west-2.eks.amazonaws.com:443"
        exit 1
fi

if [ -z ${INPUT_BUCKET+x} ];
    then
        echo "You must set the INPUT_BUCKET environment variable to a bucket containing input data";
        echo "Example: variant-spark-k-storage"
        exit 1
fi

# kubectl get secret spark-token-pjkz7 -o json | jq -r ".data.token" | base64 -d - | pbcopy
TOKEN="eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InNwYXJrLXRva2VuLWxmMnRiIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InNwYXJrIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiYWMxZThiNjAtNzUwNS0xMWU4LTk5OTctMDIxZWQ5MWQ4MzAyIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6c3BhcmsifQ.tfUeFkhJsWLZGFXsdjJDw9UhZsp5_W9r1G9Gt-UV_81OlpQQmWqrwPJgrW9ZHt5cytbakJ66caZGw7uymQN7cexC8BvQ4vFcOhtUbIP6hzGauEcS8mv3363Y5uv8Jg9rXC8Y_txcIaJEz3b9fO_Bue4fFFvR0R0XBzjVnjciVw3lNkYaWUKAizpMAEEYVJ3R8B9MlzrPR5v5qERKF0iiFKaKfxFBMp3399mM37hRW6_cawChfJEQXQ0sOJGnOLc8g7W9K1dlDGvF247sLufjto-C1QB13w-ytFlqY5hOCvct-lZIKz3-VtIX-CR-5oQbPYWfPnX5Lz1Ki4UbYmkIAA"

[[ $(type -P "spark-submit") ]] || fatal_error  "\`spark-submit\` cannot be found. Please make sure it's on your PATH."

spark-submit \
    --class au.csiro.variantspark.cli.VariantSparkApp \
    --driver-class-path ./conf \
    --master k8s://${MASTER} \
    --deploy-mode cluster \
    --name VariantSpark \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
    --conf spark.executor.instances=6 \
    --conf spark.kubernetes.container.image=jamesrcounts/variantspark:002 \
    --conf spark.kubernetes.authenticate.submission.oauthToken=${TOKEN} \
    --jars http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar,http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar,http://central.maven.org/maven2/joda-time/joda-time/2.9.9/joda-time-2.9.9.jar \
    local:///opt/spark/jars/variant-spark_2.11-0.2.0-SNAPSHOT-all.jar importance \
        -if s3a://${INPUT_BUCKET}/input/chr22_1000.vcf \
        -ff s3a://${INPUT_BUCKET}/input/chr22-labels.csv \
        -fc 22_16051249 \
        -v \
        -rn 500 \
        -rbs 20 \
        -ro "$@"
