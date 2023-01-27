#!/bin/sh
if [ "$#" -ne 2 ];  then
  echo "Usage: $0 dev-project  slack_url" >&2
  exit 1
fi

echo "Please Login to OCP using oc login ..... "  
echo "Make sure Openshift Pipeline Operator is installed"
echo "Make sure oc and tkn commands are installed"
echo "ML OpenShift Project $1"
echo "Slack url: $2"
echo "Press [Enter] key to resume..." 
read

echo "Create Required Projects … $1" 
oc new-project $1 

echo "Make sure Openshift Pipeline Operator is installed in $1 project/namespace"
echo "Press [Enter] key to resume..."
read
echo "Create Tekton Pipeline for ML Python demo App ..."
oc apply -f https://raw.githubusercontent.com/osa-ora/ml-sample-demo/main/cicd/tekton.yaml  -n $1
echo "kind: Secret
apiVersion: v1
metadata:
  name: webhook-secret
  namespace: $1
stringData:
  url: $2" | oc create -f -


echo "Make sure tkn command line tool is available in your command prompt"
echo "Press [Enter] key to resume..."
read
echo "Running Tekton pipeline for ML Python app …"
tkn pipeline start ml-plate-detection-pipeline --param first-run=true --param proj-name=$1 --param slack_enabled=true --workspace name=my-app-workspace,volumeClaimTemplateFile=https://raw.githubusercontent.com/openshift/pipelines-tutorial/pipelines-1.5/01_pipeline/03_persistent_volume_claim.yaml
echo "Done!!"
