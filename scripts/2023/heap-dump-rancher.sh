#!/bin/bash 
for pod in $(kubectl -n cattle-system get pods --no-headers -l app=rancher | cut -d ' ' -f1); do 
  echo getting profile for $pod
  
  kubectl -n cattle-system exec $pod -c rancher -- curl -s http://localhost:6060/debug/pprof/goroutine -o goroutine
  kubectl -n cattle-system exec $pod -c rancher -- curl -s http://localhost:6060/debug/pprof/heap -o heap
  kubectl -n cattle-system exec $pod -c rancher -- curl -s http://localhost:6060/debug/pprof/threadcreate -o threadcreate
  kubectl -n cattle-system exec $pod -c rancher -- curl -s http://localhost:6060/debug/pprof/block -o block
  kubectl -n cattle-system exec $pod -c rancher -- curl -s http://localhost:6060/debug/pprof/mutex -o mutex
  kubectl -n cattle-system exec $pod -c rancher -- tar -czf debug-pprof.tar.gz goroutine heap threadcreate block mutex
  kubectl -n cattle-system cp -c rancher $pod:debug-pprof.tar.gz $pod-debug-pprof.tar.gz
  echo saved debug profile $pod-debug-pprof.tar.gz
done
