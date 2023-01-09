APP_NAME=$(echo $VCAP_APPLICATION | jq -r '.application_name')
OPENSEARCH_URL=$(echo $VCAP_SERVICES | jq -r '.opensearch[] | .credentials .uri')

for index in $(curl -XGET $OPENSEARCH_URL/_cat/indices | grep $APP_NAME | awk '{print $3}')
do
  until curl -XDELETE $OPENSEARCH_URL/$index
  do
    # Snapshotting likely to be taking place
    sleep 10
  done
done