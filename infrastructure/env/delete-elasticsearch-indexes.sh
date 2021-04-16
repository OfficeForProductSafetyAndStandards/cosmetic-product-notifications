APP_NAME=$(echo $VCAP_APPLICATION | jq -r '.application_name')
ELASTICSEARCH_URL=$(echo $VCAP_SERVICES | jq -r '.elasticsearch[] | .credentials .uri')

for index in $(curl -XGET $ELASTICSEARCH_URL/_cat/indices | grep $APP_NAME | awk '{print $3}')
do
  until curl -XDELETE $ELASTICSEARCH_URL/$index
  do
    # Snapshotting likely to be taking place
    sleep 10
  done
done