#!/bin/bash
# verify docker is installed

WHITELIST_IPS="./whitelist/ips.txt"
NGINX_CONFIG="./nginx/nginx.conf"


delete_dns_iptables_rules() {
  local ip_file=$1
  local dns_port=53

  # Check if the file exists
  if [[ ! -f "$ip_file" ]]; then
    echo "IP file not found!"
    exit 1
  fi

  # Flush existing rules for port 53
#   iptables -F INPUT -t filter
#   iptables -F OUTPUT -t filter
  # Loop through each IP address in the file
  while IFS= read -r ip; do
    # Skip empty lines
    [[ -z "$ip" ]] && continue

    # Add iptables rules for both UDP and TCP on port 53
    echo "Remove iptables rule for IP: $ip"

    # Check if the rule exists before trying to remove it
    if iptables -C INPUT -p udp --dport $dns_port -s "$ip" -j ACCEPT 2>/dev/null; then
        iptables -D INPUT -p udp --dport $dns_port -s "$ip" -j ACCEPT
    else
        echo "Rule does not exist in INPUT chain."
    fi
    # Check if the rule exists before trying to remove it
    if iptables -C INPUT -p tcp --dport $dns_port -s "$ip" -j ACCEPT 2>/dev/null; then
        iptables -D INPUT -p tcp --dport $dns_port -s "$ip" -j ACCEPT
    else
        echo "Rule does not exist in INPUT chain."
    fi


    # Check if the rule exists before trying to remove it
    if iptables -C OUTPUT -p udp --dport $dns_port -s "$ip" -j ACCEPT 2>/dev/null; then
        iptables -D OUTPUT -p udp --dport $dns_port -s "$ip" -j ACCEPT
    else
        echo "Rule does not exist in OUTPUT chain."
    fi

    # Check if the rule exists before trying to remove it
    if iptables -C OUTPUT -p tcp --dport $dns_port -s "$ip" -j ACCEPT 2>/dev/null; then
        iptables -D OUTPUT -p tcp --dport $dns_port -s "$ip" -j ACCEPT
    else
        echo "Rule does not exist in OUTPUT chain."
    fi

    if iptables -C DOCKER-USER -p udp --dport $dns_port -s "$ip" -j ACCEPT 2>/dev/null; then
        iptables -D DOCKER-USER -p udp --dport $dns_port -s "$ip" -j ACCEPT
    else
        echo "Rule does not exist in DOCKER-USER chain."
    fi
    # Check if the rule exists before trying to remove it
    if iptables -C DOCKER-USER -p tcp --dport $dns_port -s "$ip" -j ACCEPT 2>/dev/null; then
        iptables -D DOCKER-USER -p tcp --dport $dns_port -s "$ip" -j ACCEPT
    else
        echo "Rule does not exist in DOCKER-USER chain."
    fi 
  done < "$ip_file"

  # Block all other IP addresses for DNS queries
  echo "Remove Blocking all other IP addresses from accessing port $dns_port"

    # Check if the rule exists before trying to remove it
    if iptables -C INPUT -p udp --dport 53 -j DROP 2>/dev/null; then
        iptables -D INPUT -p udp --dport 53 -j DROP
    else
        echo "Rule does not exist in INPUT chain."
    fi
    # Check if the rule exists before trying to remove it
    if iptables -C INPUT -p tcp --dport 53 -j DROP 2>/dev/null; then
       iptables -D INPUT -p tcp --dport 53 -j DROP
    else
        echo "Rule does not exist in INPUT chain."
    fi


    # Check if the rule exists before trying to remove it
    if iptables -C OUTPUT -p udp --dport 53 -j DROP 2>/dev/null; then
        iptables -D OUTPUT -p udp --dport 53 -j DROP
    else
        echo "Rule does not exist in OUTPUT chain."
    fi

    # Check if the rule exists before trying to remove it
    if iptables -C OUTPUT -p tcp --dport 53 -j DROP 2>/dev/null; then
        iptables -D OUTPUT -p tcp --dport 53 -j DROP
    else
        echo "Rule does not exist in OUTPUT chain."
    fi

    # Check if the rule exists before trying to remove it
    if iptables -C DOCKER-USER -p udp --dport 53 -j DROP 2>/dev/null; then
        iptables -D DOCKER-USER -p udp --dport 53 -j DROP  
    else
        echo "Rule does not exist in DOCKER-USER chain."
    fi

    # Check if the rule exists before trying to remove it
    if iptables -C DOCKER-USER -p tcp --dport 53 -j DROP 2>/dev/null; then
        iptables -D DOCKER-USER -p tcp --dport 53 -j DROP
        
    else
        echo "Rule does not exist in DOCKER-USER chain."
    fi

    if iptables -C DOCKER-USER -j RETURN 2>/dev/null; then
        echo "iptables rules updated successfully."
        
    else
        iptables -A DOCKER-USER -j RETURN
        echo "iptables rules updated successfully."
    fi
    
  
}


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

  # Flush existing rules for port 53
#   iptables -F INPUT -t filter
#   iptables -F OUTPUT -t filter
  # Loop through each IP address in the file
  while IFS= read -r ip; do
    # Skip empty lines
    [[ -z "$ip" ]] && continue

    # Add iptables rules for both UDP and TCP on port 53
    echo "Adding  iptables rule for IP: $ip"

    # Check if the rule exists before trying to remove it
    if iptables -C INPUT -p udp --dport $dns_port -s "$ip" -j ACCEPT 2>/dev/null; then
        echo "Rule exists"
    else
        iptables -A INPUT -p udp --dport $dns_port -s "$ip" -j ACCEPT
    fi
    # Check if the rule exists before trying to remove it
    if iptables -C INPUT -p tcp --dport $dns_port -s "$ip" -j ACCEPT 2>/dev/null; then
        echo "Rule exists"
    else
        iptables -A INPUT -p tcp --dport $dns_port -s "$ip" -j ACCEPT
    fi

    # Check if the rule exists before trying to remove it
    if iptables -C OUTPUT -p udp --dport $dns_port -s "$ip" -j ACCEPT 2>/dev/null; then
        echo "Rule exists"
    else
        iptables -A OUTPUT -p udp --dport $dns_port -s "$ip" -j ACCEPT
    fi

    # Check if the rule exists before trying to remove it
    if iptables -C OUTPUT -p tcp --dport $dns_port -s "$ip" -j ACCEPT 2>/dev/null; then
        echo "Rule exists"
    else
        iptables -A OUTPUT -p tcp --dport $dns_port -s "$ip" -j ACCEPT
    fi

    if iptables -C DOCKER-USER -p udp --dport $dns_port -s "$ip" -j ACCEPT 2>/dev/null; then
        echo "Rule exists"
    else
        iptables -I DOCKER-USER -p udp --dport $dns_port -s "$ip" -j ACCEPT
    fi
    # Check if the rule exists before trying to remove it
    if iptables -C DOCKER-USER -p tcp --dport $dns_port -s "$ip" -j ACCEPT 2>/dev/null; then
        echo "Rule exists"
    else
        iptables -I DOCKER-USER -p tcp --dport $dns_port -s "$ip" -j ACCEPT
    fi
  done < "$ip_file"

  # Block all other IP addresses for DNS queries
  echo "Adding Blocking all other IP addresses from accessing port $dns_port"

    # Check if the rule exists before trying to remove it
    if iptables -C INPUT -p udp --dport 53 -j DROP 2>/dev/null; then
        echo "Rule  exist in INPUT chain."       
    else
        iptables -A INPUT -p udp --dport 53 -j DROP
    fi
    # Check if the rule exists before trying to remove it
    if iptables -C INPUT -p tcp --dport 53 -j DROP 2>/dev/null; then
        echo "Rule exist in INPUT chain."
       
    else
        iptables -A INPUT -p tcp --dport 53 -j DROP
    fi


    # Check if the rule exists before trying to remove it
    if iptables -C OUTPUT -p udp --dport 53 -j DROP 2>/dev/null; then
        echo "Rule exist in OUTPUT chain."  
    else
        iptables -A OUTPUT -p udp --dport 53 -j DROP
    fi

    # Check if the rule exists before trying to remove it
    if iptables -C OUTPUT -p tcp --dport 53 -j DROP 2>/dev/null; then
        echo "Rule exist in OUTPUT chain."
        
    else
        iptables -A OUTPUT -p tcp --dport 53 -j DROP
    fi

    # Check if the rule exists before trying to remove it
    if iptables -C DOCKER-USER -p udp --dport 53 -j DROP 2>/dev/null; then
        echo "Rule exist in OUTPUT chain."  
    else
        iptables -A DOCKER-USER -p udp --dport 53 -j DROP
    fi

    # Check if the rule exists before trying to remove it
    if iptables -C DOCKER-USER -p tcp --dport 53 -j DROP 2>/dev/null; then
        echo "Rule exist in OUTPUT chain."
        
    else
        iptables -A DOCKER-USER -p tcp --dport 53 -j DROP
    fi

    if iptables -C DOCKER-USER -j RETURN 2>/dev/null; then
        iptables -D DOCKER-USER -j RETURN
        echo "iptables rules updated successfully."
        
    else
        
        echo "iptables rules updated successfully."
    fi
}



update_nginx_whitelist() {
    local ip_file=$1
    local nginx_config=$2
    local placeholder="##WHITELIST##"

    # Backup the original Nginx config
    cp "$nginx_config" "$nginx_config.back"

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
        allow_ips+="\t\tallow $ip;\n"
    done < "$ip_file"

    # Append deny all to block non-whitelisted IPs
    allow_ips+="\t\tdeny all;\n"

    # Replace the placeholder in the Nginx config with allow directives
    sed -i "/$placeholder/c\\$allow_ips" "$nginx_config"

}

remove_nginx_whitelist() {
    local nginx_config=$1
    rm $nginx_config
    cp $nginx_config.back $nginx_config
    rm $nginx_config.back
}
check_port() {
  local port=$1

  if ss -tuln | grep -q ":$port "; then
    return 0  # Port is listening
  else
    return 1  # Port is not listening
  fi
}

update_dns_config() {
    echo "changing domains address configured for this proxy"
    # update ips in dnsmasq/domains.conf file
    cp $1 $1.back
    SRV_IP=$(hostname -I | awk '{ print $1 }')
    sed -i "s/YOUR_VPS_IP/$SRV_IP/" $1
}

remove_dns_config() {
    echo "changing domains address configured for this proxy"
    # update ips in dnsmasq/domains.conf file
    rm $1
    cp $1.back $1
}
# Function to display the help message
show_help() {
    echo "Usage: $0 -i <whitelist path> -n <nginx config path> [-d]"
    echo "This script requires two arguments:"
    echo "  -i <whitelist path>    example: ./whitelist/ips.txt "
    echo "  -n <nginx config path>   example: ./nginx/nginx.conf"
    echo "  -d  remove all configs and services"
}
#########################################################################
#########################################################################
#########################################################################


# Check if no arguments are provided
if [ $# -eq 0 ]; then
    log "Error: No arguments provided."
    show_help
    exit 1
fi

iptable_removed=0
# Parse command-line arguments
  while [ $# -gt 0 ];do
      arg1=$1
      case $arg1 in 
        -i)
	    WHITELIST_IPS=$2
            shift 2
            ;;
        -n)
	    NGINX_CONFIG=$2
            shift 2
	    ;;
        -d)
        iptable_removed=1
            shift
	    ;;
      esac


  done

if [ $iptable_removed -eq 1 ];then
   delete_dns_iptables_rules $WHITELIST_IPS
   remove_dns_config "dnsmasq/domains.conf"
   remove_nginx_whitelist $NGINX_CONFIG
   docker compose down
   exit 0
fi

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

iptables-save > ./.iptables-before-run-services$(date +%s).rules

add_dns_iptables_rules $WHITELIST_IPS

update_nginx_whitelist $WHITELIST_IPS $NGINX_CONFIG

update_dns_config "dnsmasq/domains.conf"

docker compose down

docker compose up -d