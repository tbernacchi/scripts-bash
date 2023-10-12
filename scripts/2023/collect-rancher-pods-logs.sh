#!/bin/bash
for pod in $(kubectl --kubeconfig kube_config_cluster.yml get pods -n cattle-system -l app=rancher --no-headers -o custom-columns=":metadata.name");do
  kubectl --kubeconfig kube_config_cluster.yml logs -n cattle-system $pod -c rancher |& gzip > $pod.log.gz
  kubectl --kubeconfig kube_config_cluster.yml logs -n cattle-system $pod -c rancher -p |& gzip > $pod.previous.log.gz
done
