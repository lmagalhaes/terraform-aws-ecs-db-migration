#!/usr/bin/env bash
set -eu

INPUT=$(cat '/dev/stdin')
for query_value in $(echo "$INPUT" | jq -r 'to_entries|map("\(.key|ascii_upcase)=\(.value|tostring)")|.[]'); do
  export "$query_value"
done

export AWS_DEFAULT_REGION="$REGION"

# If ASSUME_ROLE_ARN is given
if [[ "${ASSUME_ROLE_ARN}" != "" ]]; then
  ASSUMED_ROLE_CREDENTIALS=$(aws sts assume-role --role-arn "$ASSUME_ROLE_ARN" --role-session-name 'migration-session')
  export AWS_ACCESS_KEY_ID=$(echo $ASSUMED_ROLE_CREDENTIALS | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo $ASSUMED_ROLE_CREDENTIALS | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo $ASSUMED_ROLE_CREDENTIALS | jq -r '.Credentials.SessionToken')
fi;

OVERRIDE_TEMPLATE=$(echo "$OVERRIDE_TEMPLATE" | base64 -d)

TASK_DETAILS=$(aws ecs run-task \
  --overrides "$OVERRIDE_TEMPLATE" \
  --cluster "$CLUSTER_NAME" \
  --task-definition "$TASK_DEFINITION_ARN")

TASK_ARN=$(echo "$TASK_DETAILS" | jq -r '.tasks[].taskArn')
TASK_ID=$(echo "$TASK_ARN" | awk -F '/' '{print $NF}')

# Wait for ecs task to stop
aws ecs wait tasks-stopped \
  --cluster "$CLUSTER_NAME" \
  --tasks "$TASK_ARN"

# Get exit code
MIGRATION_CONTAINER_DETAILS=$(aws ecs describe-tasks \
  --cluster "$CLUSTER_NAME" \
  --tasks "$TASK_ARN" \
  --query "tasks[0].containers[?name=='$MIGRATION_CONTAINER_NAME']" | jq -r '.[]')

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

CONTAINER_EXIT_CODE=$(echo "$MIGRATION_CONTAINER_DETAILS" | jq -r '.exitCode')
if [[ "$CONTAINER_EXIT_CODE" != "0" ]]; then
  echo "$MIGRATION_CONTAINER_DETAILS" > '/dev/stderr'
  echo 'Migration failed. Please check the stack strace above, or check Datadog logs for more info' > '/dev/stderr'
  exit "$CONTAINER_EXIT_CODE"
fi

echo "$MIGRATION_CONTAINER_DETAILS" \
  | jq 'with_entries(select(.value | (type != "array" and type != "object")))' \
  | jq -c -j 'walk(if type == "number" then tostring else . end)'

exit 0
