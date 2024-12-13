kubeadm init phase certs ca --config=/opt/kubeadmcfg.yaml
kubeadm init phase certs front-proxy-ca --config=/opt/kubeadmcfg.yaml
kubeadm init phase certs sa --cert-dir=/etc/kubernetes/pki
