#!/bin/bash

if [[ ! $(whoami) = "root" ]]
then
    echo "Usage: Must be root"
    exit 1
fi


while getopts ":d:n:" opt; do
  case $opt in
    d) DOMAIN=${OPTARG} ;;
    n) K8S_N=${OPTARG} ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

if [[ -z $DOMAIN ]]
then
    echo 'Flag -d is required'
    exit 1
fi

if [[ -z $K8S_N ]]
then
    echo 'Flag -n is required'
    exit 1
fi

if [ -d run ]
then
    chmod u=rwx cleanup.sh
    ./cleanup.sh
fi
mkdir run
cp -r dns run/dns
cp -r nfs run/nfs
cp -r vpn run/vpn
cp -r main run/main
for (( i=1; i<=$K8S_N; i++ ))
do
    cp -r worker run/worker$i
done

sed -i "s/\[\[DOMAIN\]\]/$DOMAIN/g" run/dns/initscripts/ansible-dns.yaml
sed -i "s/\[\[DOMAIN\]\]/$DOMAIN/g" run/dns/initscripts/test-dns.sh
sed -i "s/\[\[DOMAIN\]\]/$DOMAIN/g" run/dns/initscripts/script-dns.sh
sed -i "s/\[\[DOMAIN\]\]/$DOMAIN/g" run/nfs/initscripts/ansible-nfs.yaml
sed -i "s/\[\[DOMAIN\]\]/$DOMAIN/g" run/nfs/initscripts/test-nfs.sh
sed -i "s/\[\[DOMAIN\]\]/$DOMAIN/g" run/nfs/initscripts/script-nfs.sh
sed -i "s/\[\[DOMAIN\]\]/$DOMAIN/g" run/main/initscripts/mainkubeinstall.sh
sed -i "s/\[\[DOMAIN\]\]/$DOMAIN/g" run/main/jenkins/jenkins-ingress.yaml
sed -i "s/\[\[DOMAIN\]\]/$DOMAIN/g" run/main/jenkins/jenkins-pv.yaml
sed -i "s/\[\[DOMAIN\]\]/$DOMAIN/g" run/main/tls/myapp-ingress-tls.yaml
for (( i=1; i<=$K8S_N; i++ ))
do
    sed -i "s/\[\[DOMAIN\]\]/$DOMAIN/g" run/worker$i/initscripts/workerkubeinstall.sh
    sed -i "s/\[\[WORKER_N\]\]/$i/g" run/worker$i/Vagrantfile
    ip=$(( $i + 10 ))
    sed -i "s/\[\[WORKER_IP\]\]/$ip/g" run/worker$i/Vagrantfile
done
