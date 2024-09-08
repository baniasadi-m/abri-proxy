#!/bin/bash
# verify docker is installed
check_docker_installed()
{
    if ! hash docker 2>/dev/null
    then
        echo "docker command not found. You have to install docker first."
        exit 1
    fi
}



check_port() {
  local port=$1

  if ss -tuln | grep -q ":$port "; then
    return 0  # Port is listening
  else
    return 1  # Port is not listening
  fi
}


check_docker_installed

check_port 80
if [ $? -eq 0 ]; then
  echo "Port 80 is listening.Please check and stop service used it"
  exit 1
else
  echo "OK! Port 80 is FREE."
fi

check_port 443
if [ $? -eq 0 ]; then
  echo "Port 443 is listening.Please check and stop service used it"
  exit 1
else
  echo "OK! Port 443 is FREE."
fi

check_port 53
if [ $? -eq 0 ]; then
  echo "Port 53 is listening.Please check and stop service used it"
  exit 1
else
  echo "OK! Port 53 is FREE."
fi


systemctl stop systemd-resolved


echo "changing domains address configured for this proxy"
# update ips in dnsmasq/domains.conf file
SRV_IP=$(hostname -I | awk '{ print $1 }')
sed -i "s/YOUR_VPS_IP/$SRV_IP/" dnsmasq/domains.conf

docker compose down

docker compose up -d