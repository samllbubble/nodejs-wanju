#!/bin/bash

# Define Environment Variables
export V_PORT=${V_PORT:-'8080'}
export CFPORT=${CFPORT:-'443'} # https 443 2053 2083 2087 2096 8443  # http 80 8080 8880 2052 2082 2086 2095
export VMESS_WSPATH=${VMESS_WSPATH:-'startvm'}
export VLESS_WSPATH=${VLESS_WSPATH:-'startvl'}
export CF_IP=${CF_IP:-'ip.sb'}
export FILE_PATH=${FILE_PATH:-'./.npm'}

export SUB_URL=${SUB_URL:-'https://sub.smartdns.eu.org/upload-ea4909ef-7ca6-4b46-bf2e-6c07896ef338'}
export SUB_NAME=${SUB_NAME:-'Meteor.com'}

# 哪吒参数，NEZHA_SERVER和NEZHA_KEY不填不安装哪吒
export UUID=${UUID:-'7160b696-dd5e-42e3-a024-145e92cec916'}  # 这个要填，节点uuid及哪吒V1uuid共用
export NEZHA_VERSION=${NEZHA_VERSION:-'V0'} # V0 OR V1
export NEZHA_SERVER=${NEZHA_SERVER:-'nazhe.841013.xyz'}
export NEZHA_KEY=${NEZHA_KEY:-'BYONQlcze9fY4QMDmD'}
export NEZHA_PORT=${NEZHA_PORT:-'443'}

export ARGO_DOMAIN=${ARGO_DOMAIN:-''}
export ARGO_AUTH=${ARGO_AUTH:-''}

hint() { echo -e "\033[33m\033[01m$*\033[0m"; }   # yellow

if [ ! -d "$FILE_PATH" ]; then
  mkdir -p "$FILE_PATH"
fi

cleanup_files() {
  rm -rf ${FILE_PATH}/*.log ${FILE_PATH}/*.txt ${FILE_PATH}/*.sh
}

# Download Dependency Files
set_download_url() {
  local program_name="$1"
  local default_url="$2"
  local x64_url="$3"

  if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "amd64" ] || [ "$(uname -m)" = "x64" ]; then
    download_url="$x64_url"
  else
    download_url="$default_url"
  fi
}

download_program() {
  local program_name="$1"
  local default_url="$2"
  local x64_url="$3"

  set_download_url "$program_name" "$default_url" "$x64_url"

  if [ ! -f "$program_name" ]; then
    if [ -n "$download_url" ]; then
      echo "Downloading $program_name..." > /dev/null
      # wget -q -O "$program_name" "$download_url"
      curl -sSL "$download_url" -o "$program_name"
      echo "Downloaded $program_name" > /dev/null
    else
      echo "Skipping download for $program_name" > /dev/null
    fi
  else
    echo "$program_name already exists, skipping download" > /dev/null
  fi
}

initialize_downloads() {
  if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_KEY}" ]; then
    case "$NEZHA_VERSION" in
      "V0" )
        download_program "${FILE_PATH}/npm" "https://github.com/kahunama/myfile/releases/download/main/nezha-agent_arm" "https://github.com/kahunama/myfile/releases/download/main/nezha-agent"
        ;;
      "V1" )
        download_program "${FILE_PATH}/npm" "https://github.com/mytcgd/myfiles/releases/download/main/nezha-agentv1_arm" "https://github.com/mytcgd/myfiles/releases/download/main/nezha-agentv1"
        ;;
    esac
    sleep 3
    chmod +x ${FILE_PATH}/npm
  fi

  download_program "${FILE_PATH}/web" "https://github.com/mytcgd/myfiles/releases/download/main/xray_arm" "https://github.com/mytcgd/myfiles/releases/download/main/xray"
  sleep 3
  chmod +x ${FILE_PATH}/web

  download_program "${FILE_PATH}/server" "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64" "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
  sleep 3
  chmod +x ${FILE_PATH}/server
}

# check_chatgpt
check_chatgpt() {
  local SUPPORT_COUNTRY=(AD AE AF AG AL AM AO AR AT AU AZ BA BB BD BE BF BG BH BI BJ BN BO BR BS BT BW BZ CA CD CF CG CH CI CL CM CO CR CV CY CZ DE DJ DK DM DO DZ EC EE EG ER ES ET FI FJ FM FR GA GB GD GE GH GM GN GQ GR GT GW GY HN HR HT HU ID IE IL IN IQ IS IT JM JO JP KE KG KH KI KM KN KR KW KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MG MH MK ML MM MN MR MT MU MV MW MX MY MZ NA NE NG NI NL NO NP NR NZ OM PA PE PG PH PK PL PS PT PW PY QA RO RS RW SA SB SC SD SE SG SI SK SL SM SN SO SR SS ST SV SZ TD TG TH TJ TL TM TN TO TR TT TV TW TZ UA UG US UY UZ VA VC VN VU WS YE ZA ZM ZW)
  [[ "${SUPPORT_COUNTRY[@]}" =~ $(curl -s -k -m 2 https://chat.openai.com/cdn-cgi/trace | awk -F '=' '/loc/{print $2}') ]] && echo 'unlock' || echo 'ban'
  # [[ "${SUPPORT_COUNTRY[@]}" =~ $(wget --no-check-certificate -qO- --tries=3 --timeout=2 https://chat.openai.com/cdn-cgi/trace | awk -F '=' '/loc/{print $2}') ]] && echo 'unlock' || echo 'ban'
}

# my_config
my_config() {
  # Check whether chatGPT is unlocked
  if [ "$(check_chatgpt)" = 'unlock' ]; then
    CHAT_GPT_OUT="direct"
  else
    CHAT_GPT_OUT="WARP"
  fi

  if [[ ! "$SERVER_IP" =~ : ]]; then
    WARP_ENDPOINT=162.159.193.10
  else
    WARP_ENDPOINT=2606:4700:d0::a29f:c101
  fi

  generate_config() {
  cat > ${FILE_PATH}/out.json << EOF
{
    "log": {
        "access": "/dev/null",
        "error": "/dev/null",
        "loglevel": "none"
    },
    "dns": {
        "servers": [
            "https+local://8.8.8.8/dns-query"
        ]
    },
    "inbounds": [
        {
            "port": $V_PORT,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${UUID}",
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none",
                "fallbacks": [
                    {
                        "path": "/${VLESS_WSPATH}",
                        "dest": 3002
                    },
                    {
                        "path": "/${VMESS_WSPATH}",
                        "dest": 3003
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp"
            }
        },
        {
            "port": 3002,
            "listen": "127.0.0.1",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${UUID}",
                        "level": 0
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "path": "/${VLESS_WSPATH}"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly": false
            }
        },
        {
            "port": 3003,
            "listen": "127.0.0.1",
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "${UUID}",
                        "alterId": 0
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/${VMESS_WSPATH}"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly": false
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "tag": "WARP",
            "protocol": "wireguard",
            "settings": {
                "secretKey": "YFYOAdbw1bKTHlNNi+aEjBM3BO7unuFC5rOkMRAz9XY=",
                "address": [
                    "172.16.0.2/32",
                    "2606:4700:110:8a36:df92:102a:9602:fa18/128"
                ],
                "peers": [
                    {
                        "publicKey": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
                        "allowedIPs": [
                            "0.0.0.0/0",
                            "::/0"
                        ],
                        "endpoint": "${WARP_ENDPOINT}:2408"
                    }
                ],
                "reserved": [78, 135, 76],
                "mtu": 1280
            }
        }
    ],
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "type": "field",
                "domain": [
                    "domain:openai.com",
                    "domain:ai.com",
                    "domain:chat.openai.com",
                    "domain:chatgpt.com"
                ],
                "outboundTag": "${CHAT_GPT_OUT}"
            }
        ]
    }
}
EOF
  }

  argo_type() {
    if [ -z "$ARGO_AUTH" ] && [ -z "$ARGO_DOMAIN" ]; then
      echo "ARGO_AUTH or ARGO_DOMAIN is empty, use Quick Tunnels" > /dev/null
      return
    fi

    if [ -n "$(echo "$ARGO_AUTH" | grep TunnelSecret)" ]; then
      echo $ARGO_AUTH > ${FILE_PATH}/tunnel.json
      cat > ${FILE_PATH}/tunnel.yml << EOF
tunnel=$(echo "$ARGO_AUTH" | cut -d\" -f12)
credentials-file: ${FILE_PATH}/tunnel.json
protocol: http2

ingress:
  - hostname: $ARGO_DOMAIN
    service: http://localhost: $V_PORT
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF
    else
      echo "ARGO_AUTH Mismatch TunnelSecret" > /dev/null
    fi
  }

  args() {
    if [ -e "${FILE_PATH}/server" ]; then
      if [ -n "$(echo "$ARGO_AUTH" | grep '^[A-Z0-9a-z=]\{120,250\}$')" ]; then
        args="tunnel --edge-ip-version auto --no-autoupdate --protocol http2 run --token ${ARGO_AUTH}"
      elif [ -n "$(echo "$ARGO_AUTH" | grep TunnelSecret)" ]; then
        args="tunnel --edge-ip-version auto --config ${FILE_PATH}/tunnel.yml run"
      else
        args="tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile ${FILE_PATH}/boot.log --loglevel info --url http://localhost:${V_PORT}"
      fi
    fi
  }

  generate_config
  argo_type
  args
}

# run
run_server() {
  if [ -e "${FILE_PATH}/server" ]; then
    ${FILE_PATH}/server $args > /dev/null 2>&1 &
  fi
}

run_web() {
  if [ -e "${FILE_PATH}/web" ]; then
    ${FILE_PATH}/web run -c ${FILE_PATH}/out.json >/dev/null 2>&1 &
  fi
}

run_npm() {
  if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_KEY}" ]; then
    case "$NEZHA_VERSION" in
      "V0" )
        tlsPorts=("443" "8443" "2096" "2087" "2083" "2053")
        if [[ " ${tlsPorts[@]} " =~ " ${NEZHA_PORT} " ]]; then
          NEZHA_TLS="--tls"
        else
          NEZHA_TLS=""
        fi
        ${FILE_PATH}/npm -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${NEZHA_TLS} > /dev/null 2>&1 &
        ;;
      "V1" )
        tlsPorts=("443" "8443" "2096" "2087" "2083" "2053")
        if [[ " ${tlsPorts[@]} " =~ " ${NEZHA_PORT} " ]]; then
          NEZHA_TLS="true"
        else
          NEZHA_TLS="false"
        fi
        cat > ${FILE_PATH}/config.yml << ABC
client_secret: $NEZHA_KEY
debug: false
disable_auto_update: true
disable_command_execute: false
disable_force_update: true
disable_nat: false
disable_send_query: false
gpu: false
insecure_tls: false
ip_report_period: 1800
report_delay: 4
server: $NEZHA_SERVER:$NEZHA_PORT
skip_connection_count: true
skip_procs_count: true
temperature: false
tls: $NEZHA_TLS
use_gitee_to_upgrade: false
use_ipv6_country_code: false
uuid: $UUID
ABC
        ${FILE_PATH}/npm -c ${FILE_PATH}/config.yml > /dev/null 2>&1 &
        ;;
    esac
  fi
}

run_processes() {
  [ -e "${FILE_PATH}/server" ] && run_server
  sleep 5
  [ -e "${FILE_PATH}/web" ] && run_web
  [ -e "${FILE_PATH}/npm" ] && run_npm
  sleep 1

  check_hostname_change && sleep 3 && build_urls

  if [ -n "$SUB_URL" ]; then
    if [ ! -s "${FILE_PATH}/boot.log" ]; then
      upload_subscription
    else
      while true; do
        upload_subscription
        sleep 90
        check_hostname_change
        # build_urls
        sleep 10
      done
    fi
  fi
}

# get IP and country
get_ip_country_code() {
  export SERVER_IP=$(curl -s https://speed.cloudflare.com/meta | tr ',' '\n' | grep -E '"clientIp"\s*:\s*"' | sed 's/.*"clientIp"\s*:\s*"\([^"]*\)".*/\1/')
  # export SERVER_IP=$(curl -s https://ipinfo.io/ip)
  # echo "${SERVER_IP}"

  export country_abbreviation=$(curl -s https://speed.cloudflare.com/meta | awk -F\" '{print $26"-"$18}' | sed -e 's/ /_/g')   # Display ISP and country abbreviation
  # export country_abbreviation=$(curl -s https://speed.cloudflare.com/meta | tr ',' '\n' | grep -E '"country"\s*:\s*"' | sed 's/.*"country"\s*:\s*"\([^"]*\)".*/\1/')   # Display country abbreviation
  # echo "${country_abbreviation}"
}

# general_upload_data
general_upload_data() {
  VMESS="{ \"v\": \"2\", \"ps\": \"${country_abbreviation}-${SUB_NAME}\", \"add\": \"${CF_IP}\", \"port\": \"${CFPORT}\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"${ARGO_DOMAIN}\", \"path\": \"/${VMESS_WSPATH}?ed=2048\", \"tls\": \"tls\", \"sni\": \"${ARGO_DOMAIN}\", \"alpn\": \"\" }"
  vmess_url="vmess://$(echo "$VMESS" | base64 | tr -d '\n')"
  vless_url="vless://${UUID}@${CF_IP}:${CFPORT}?host=${ARGO_DOMAIN}&path=%2F${VLESS_WSPATH}%3Fed%3D2048&type=ws&encryption=none&security=tls&sni=${ARGO_DOMAIN}#${country_abbreviation}-${SUB_NAME}"
  # UPLOAD_DATA="$vmess_url\n$vless_url"
  export UPLOAD_DATA="$vless_url"
}

# check_hostname
check_hostname_change() {
  if [ -s "${FILE_PATH}/boot.log" ]; then
    export ARGO_DOMAIN=$(cat ${FILE_PATH}/boot.log | grep -o "info.*https://.*trycloudflare.com" | sed "s@.*https://@@g" | tail -n 1)
    # export ARGO_DOMAIN=$(cat ${FILE_PATH}/boot.log | grep -o "https://.*trycloudflare.com" | tail -n 1 | sed 's/https:\/\///')
  fi
  general_upload_data
}

# build_urls
build_urls() {
  cat > ${FILE_PATH}/tmp.txt << DEF
$vmess_url
$vless_url
DEF
  base64 ${FILE_PATH}/tmp.txt | tr -d '\n' > ${FILE_PATH}/log.txt
  rm -rf ${FILE_PATH}/tmp.txt ${FILE_PATH}/npm ${FILE_PATH}/web ${FILE_PATH}/server ${FILE_PATH}/config.yml ${FILE_PATH}/out.json ${FILE_PATH}/tunnel.*
}

# upload
upload_subscription() {
  if command -v curl &> /dev/null; then
    response=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"URL_NAME\":\"$SUB_NAME\",\"URL\":\"$UPLOAD_DATA\"}" $SUB_URL)
  elif command -v wget &> /dev/null; then
    response=$(wget -qO- --post-data="{\"URL_NAME\":\"$SUB_NAME\",\"URL\":\"$UPLOAD_DATA\"}" --header="Content-Type: application/json" $SUB_URL)
  fi
}

# main
main() {
  cleanup_files
  initialize_downloads
  get_ip_country_code
  my_config
  run_processes
}
main

# tail -f /dev/null
