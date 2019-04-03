#! /bin/sh

COMMAND=${COMMAND:-sam}

function cleanUp {
	echo $1 | sed -e 's/\[/\\[/g' -e 's/\]/\\]/g' -e 's/\$/\\$/g' -e 's/"//g'
}

function events() {
	NAME=$1
	echo
	mkdir -p target

	cat << EOF > target/log.sh
aws logs get-log-events \\
     --log-group-name /aws/lambda/bash-runtime \\
     --log-stream-name $NAME \\
     | jq '.events[].message' | sed -e 's|\\\\n||g' -e 's/^"//' -e 's/"$//' -e 's/\\\t/ /g'
EOF
	LOGFILE=target/$( echo ${NAME}.log | cut -d \] -f2 )
	echo Getting events for $NAME in to $LOGFILE
    sh target/log.sh > $LOGFILE
    rm -f target/log.sh
}

function names() {
	aws logs describe-log-streams --log-group-name /aws/lambda/bash-runtime | \
		jq '.logStreams[].logStreamName'
}

function dump() {
    names | while read NAME
    do
        events $( cleanUp $NAME )
    done
}

function clearStreams() {
mkdir -p target

names | while read NAME
    do
        NAME=$( cleanUp $NAME )
        cat << EOF > target/log.sh
aws logs delete-log-stream \\
     --log-group-name /aws/lambda/bash-runtime \\
     --log-stream-name $NAME
EOF

    sh target/log.sh
    rm -f target/$( echo ${NAME}.log | cut -d \] -f2 )

    done
}