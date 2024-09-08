#!/bin/bash
# verify docker is installed

WHITELIST_IPS="./whitelist/ips.txt"
NGINX_CONFIG="./nginx/nginx.conf"


check_docker_installed()
{
    if ! hash docker 2>/dev/null
    then
        echo "docker command not found. You have to install docker first."
        exit 1
    fi
}


# Define a function to add IPs to iptables
add_dns_iptables_rules() {
  local ip_file=$1
  local dns_port=53

  # Check if the file exists
  if [[ ! -f "$ip_file" ]]; then
    echo "IP file not found!"
    exit 1
  fi

  # Loop through each IP address in the file
  while IFS= read -r ip; do
    # Skip empty lines
    [[ -z "$ip" ]] && continue
    
    # Add iptables rules for both UDP and TCP on port 53
    echo "Adding iptables rule for IP: $ip"
    iptables -A DOCKER-USER -p udp --dport $dns_port -s "$ip" -j ACCEPT
    iptables -A DOCKER-USER -p tcp --dport $dns_port -s "$ip" -j ACCEPT
  done < "$ip_file"

  # Block all other IP addresses for DNS queries
  echo "Blocking all other IP addresses from accessing port $dns_port"
  iptables -A DOCKER-USER -p udp --dport $dns_port -j DROP
  iptables -A DOCKER-USER -p tcp --dport $dns_port -j DROP

  echo "iptables rules updated successfully."
}

update_nginx_whitelist() {
    local ip_file=$1
    local nginx_config=$2
    local placeholder="##WHITELIST##"

    # Backup the original Nginx config
    cp "$nginx_config" "$nginx_config.bak"

    # Prepare the list of allow directives
    allow_ips=""

    # Check if the IP file exists
    if [[ ! -f "$ip_file" ]]; then
        echo "IP file not found: $ip_file"
        return 1
    fi

    # Read the IP file and generate allow directives
    while IFS= read -r ip; do
        [[ -z "$ip" ]] && continue  # Skip empty lines
        allow_ips+="allow $ip;\n"
    done < "$ip_file"

    # Append deny all to block non-whitelisted IPs
    allow_ips+="deny all;\n"

    # Replace the placeholder in the Nginx config with allow directives
    sed -i "/$placeholder/c\\$allow_ips" "$nginx_config"

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

add_dns_iptables_rules $WHITELIST_IPS

update_nginx_whitelist $WHITELIST_IPS $NGINX_CONFIG

systemctl stop systemd-resolved


echo "changing domains address configured for this proxy"
# update ips in dnsmasq/domains.conf file
SRV_IP=$(hostname -I | awk '{ print $1 }')
sed -i "s/YOUR_VPS_IP/$SRV_IP/" dnsmasq/domains.conf

docker compose down

docker compose up -d