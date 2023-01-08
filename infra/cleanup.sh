#!/usr/bin/env bash

for function_delete in $( gcloud functions list --format="value(name)");do
    if [ "$function_delete" != "redis-function" ];
     then
        gcloud functions delete  --region=europe-west1 -q --project cloud-function-hands-on "${function_delete}"
        gcloud functions delete  --region=europe-west1 --gen2 -q --project cloud-function-hands-on "${function_delete}"
    fi
done

for topic_delete in $(gcloud pubsub topics  list --format="value(name)");do
  gcloud pubsub topics delete -q --project cloud-function-hands-on "${topic_delete}"
done
