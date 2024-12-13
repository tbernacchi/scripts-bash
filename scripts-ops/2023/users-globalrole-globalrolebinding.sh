#!/bin/bash
kubectl get globalrolebindings -o jsonpath='{range .items[*]}{@.userName}{" "}{@.globalRoleName}{" "}{"\n"}{end}' | while read line; do
  rancherName=$(echo $line | cut -d ' ' -f1);
  globalrole=$(echo $line | cut -d ' ' -f2);
  append=$(kubectl get users $rancherName -o jsonpath='{.displayName}');
  echo "Display Name => '$append'; Local user => '$rancherName';  Global Role => '$globalrole'";
done
