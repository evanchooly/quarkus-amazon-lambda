#!/usr/bin/env bash

source dump-aws-logs.sh

APPDIR=target/
BUNDLEDIR=target/bundle

function bundle() {
    rm -f response.txt

    mvn clean package -DskipTests=true -Dnative=true -Dnative-image.docker-build=true

    mkdir -p ${BUNDLEDIR}
    cp -r target/wiring-classes/bootstrap ${APPDIR}/*-runner* ${APPDIR}/lib ${BUNDLEDIR}
    chmod 755 ${BUNDLEDIR}/bootstrap
    cd ${BUNDLEDIR} && zip -q function.zip bootstrap function.sh *-runner* lib/* ; cd -

    if [[ 2 == 1 ]]
    then
        unzip -l ${BUNDLEDIR}/function.zip
        exit
    fi
}

[ -z "$NOBUNDLE" ] && bundle

clearStreams

echo Deleting old function
aws lambda delete-function \
    --function-name quarkus-poc

echo Creating function
aws lambda create-function \
    --function-name quarkus-poc \
    --timeout 10 \
    --zip-file fileb://${BUNDLEDIR}/function.zip \
    --handler function.sh \
    --runtime provided \
    --role ${LAMBDA_ROLE_ARN}

echo
time aws lambda invoke --function-name quarkus-poc --payload '{"firstName":"James", "lastName": "Lipton"}' response.txt
cat response.txt
echo

echo
time aws lambda invoke --function-name quarkus-poc --payload '{"firstName":"James", "lastName": "Halpert"}' response.txt
cat response.txt
echo

echo
time aws lambda invoke --function-name quarkus-poc --payload '{"firstName":"James", "lastName": "Jamm"}' response.txt
cat response.txt
echo

dump
