#!/bin/bash
#The machine needs kubectl with it's context pointing to the upstream cluster.
#https://github.com/rancherlabs/support-kb/wiki/One-Liners#disable-v1-monitoring
 
cid="your-clusterid"
 
for clusterId in $(kubectl get clusters.management.cattle.io -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep -i $cid );
do
  # empty recipients for cluster alert groups
  for clusterAlertGroup in $(kubectl -n $clusterId get clusteralertgroups -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}');
  do
    kubectl -n $clusterId patch clusteralertgroup $clusterAlertGroup --type merge --patch '{"spec": {"recipients": []}}'
  done
 
  # disable cluster monitoring
  kubectl patch clusters.management.cattle.io $clusterId --type merge --patch '{"spec": {"enableClusterMonitoring": false}}'
 
  for projectId in $(kubectl -n $clusterId get projects.management.cattle.io -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')
  do
    # empty recipients for all project alert groups
    for projectalertgroup in $(kubectl -n $projectId get projectalertgroups -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}');
    do
      kubectl -n $projectId patch projectalertgroup $projectalertgroup --type merge --patch '{"spec": {"recipients": []}}'
    done
 
    # disable project monitoring
    kubectl -n $clusterId patch projects.management.cattle.io $projectId --type merge --patch '{"spec": {"enableProjectMonitoring:": false}}'
 
    # delete the project monitoring app
    kubectl -n $projectId delete apps.project.cattle.io cluster-monitoring monitoring-operator project-monitoring

    # clean apprevisions for cleanliness
    kubectl -n $projectId delete apprevisions -l io.cattle.field/appId=monitoring-operator
    kubectl -n $projectId delete apprevisions -l io.cattle.field/appId=cluster-monitoring
    kubectl -n $projectId delete apprevisions  -l io.cattle.field/appId=project-monitoring
  done
done 
