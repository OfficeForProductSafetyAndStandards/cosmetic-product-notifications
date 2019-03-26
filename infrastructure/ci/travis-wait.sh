#!/usr/bin/env bash

# Output something every 9 minutes or Travis will kill the job
while sleep 540; do echo "Travis keep-alive..."; done &

$@
EXIT_CODE=$?

kill %1

exit $EXIT_CODE
