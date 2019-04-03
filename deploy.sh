#!/usr/bin/env bash

source dump-aws-logs.sh

APPDIR=target/
BUNDLEDIR=target/bundle

function bundle() {
    rm -f response.txt

    mvn clean package -DskipTests=true -Dnative=true -Dnative-image.docker-build=true

    mkdir -p ${BUNDLEDIR} target

    cp -r target/bootstrap ${BUNDLEDIR}
    chmod 755 ${BUNDLEDIR}/bootstrap
    cp -r ${APPDIR}/*-runner* ${APPDIR}/lib ${BUNDLEDIR}
    cd ${BUNDLEDIR} && zip -q function.zip bootstrap function.sh *-runner* lib/* ; cd -

    if [[ 2 == 1 ]]
    then
        unzip -l ${BUNDLEDIR}/function.zip
        exit
    fi
}

bundle

clearStreams

echo Deleting old function
aws lambda delete-function \
    --function-name bash-runtime

echo Creating function
aws lambda create-function \
    --function-name bash-runtime \
    --timeout 10 \
    --zip-file fileb://${BUNDLEDIR}/function.zip \
    --handler function.sh \
    --runtime provided \
    --role ${LAMBDA_ROLE_ARN}

echo
aws lambda invoke --function-name bash-runtime --payload '{"firstName":"James", "lastName": "Lipton"}' response.txt
cat response.txt
echo

echo
aws lambda invoke --function-name bash-runtime --payload '{"firstName":"James", "lastName": "Halpert"}' response.txt
cat response.txt
echo

echo
aws lambda invoke --function-name bash-runtime --payload '{"firstName":"James", "lastName": "Jamm"}' response.txt
cat response.txt
echo

dump

cat target/*.log