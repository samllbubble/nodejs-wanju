#!/bin/bash

# Define Environment Variables
export V_PORT=${V_PORT:-'8080'}
export CFPORT=${CFPORT:-'8443'} # https 443 2053 2083 2087 2096 8443  # http 80 8080 8880 2052 2082 2086 2095
export CF_IP=${CF_IP:-'ip.sb'}
export SNI=${SNI:-'www.zara.com'}
export FILE_PATH=${FILE_PATH:-'./.npm'}

# export REAL_PORT="$SERVER_PORT"  # 默认reality端口，如果想默认用另外二个协议，可以把REAL_PORT换成别的端口名，并注释下面这个端口名。如果哪个协议不用也可以把下面该协议端口那句删除。不影响
export HY2_PORT=${HY2_PORT:-''}   # 有开放端口设置，没有不管或删除
export TUIC_PORT=${TUIC_PORT:-''}  # 有开放端口设置，没有不管或删除
export REAL_PORT=${REAL_PORT:-''}  # 有开放端口设置，没有不管或删除

export openkeepalive=${openkeepalive:-'0'} # openkeepalive为0时不保活进程，为1时保活进程

export SUB_URL=${SUB_URL:-'https://sub.smartdns.eu.org/upload-ea4909ef-7ca6-4b46-bf2e-6c07896ef338'}
export SUB_NAME=${SUB_NAME:-'Meteor.com'}

export UUID=${UUID:-'7160b696-dd5e-42e3-a024-145e92cec916'}
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
  rm -rf ${FILE_PATH}/sconf && mkdir -p "${FILE_PATH}/sconf"
  rm -rf ${FILE_PATH}/*.yml ${FILE_PATH}/*.json ${FILE_PATH}/*.log ${FILE_PATH}/*.txt ${FILE_PATH}/*.sh ${FILE_PATH}/cert.pem ${FILE_PATH}/private.key ${FILE_PATH}/cache.db
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
      # wget -qO "$program_name" "$download_url"
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

  download_program "${FILE_PATH}/web" "https://github.com/mytcgd/myfiles/releases/download/main/sing-box_arm" "https://github.com/mytcgd/myfiles/releases/download/main/sing-box"
  sleep 3
  chmod +x ${FILE_PATH}/web

  download_program "${FILE_PATH}/server" "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64" "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
  sleep 3
  chmod +x ${FILE_PATH}/server

  if [ -n "${SUB_URL}" ]; then
    download_program "${FILE_PATH}/up.sh" "https://raw.githubusercontent.com/mytcgd/myfiles/main/my/sb/up_s_sb.sh" "https://raw.githubusercontent.com/mytcgd/myfiles/main/my/sb/up_s_sb.sh"
    sleep 1
    chmod +x ${FILE_PATH}/up.sh
  fi
}

# check_chatgpt
check_chatgpt() {
  local SUPPORT_COUNTRY=(AD AE AF AG AL AM AO AR AT AU AZ BA BB BD BE BF BG BH BI BJ BN BO BR BS BT BW BZ CA CD CF CG CH CI CL CM CO CR CV CY CZ DE DJ DK DM DO DZ EC EE EG ER ES ET FI FJ FM FR GA GB GD GE GH GM GN GQ GR GT GW GY HN HR HT HU ID IE IL IN IQ IS IT JM JO JP KE KG KH KI KM KN KR KW KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MG MH MK ML MM MN MR MT MU MV MW MX MY MZ NA NE NG NI NL NO NP NR NZ OM PA PE PG PH PK PL PS PT PW PY QA RO RS RW SA SB SC SD SE SG SI SK SL SM SN SO SR SS ST SV SZ TD TG TH TJ TL TM TN TO TR TT TV TW TZ UA UG US UY UZ VA VC VN VU WS YE ZA ZM ZW)
  [[ "${SUPPORT_COUNTRY[@]}" =~ $(curl -s -k -m 2 https://chat.openai.com/cdn-cgi/trace | awk -F '=' '/loc/{print $2}') ]] && echo 'unlock' || echo 'ban'
  # [[ "${SUPPORT_COUNTRY[@]}" =~ $(wget --no-check-certificate -qO- --tries=3 --timeout=2 https://chat.openai.com/cdn-cgi/trace | awk -F '=' '/loc/{print $2}') ]] && echo 'unlock' || echo 'ban'
}

# Generating Configuration Files
my_config() {
  generate_config() {
    output=$(${FILE_PATH}/web generate reality-keypair)
    private_key=$(echo "${output}" | grep -E 'PrivateKey:' | cut -d: -f2- | sed 's/^\s*//' )
    export public_key=$(echo "${output}" | grep -E 'PublicKey:' | cut -d: -f2- | sed 's/^\s*//' )
    export tuicpass=$(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c 24)

    openssl ecparam -genkey -name prime256v1 -out "${FILE_PATH}/private.key"
    openssl req -new -x509 -days 3650 -key "${FILE_PATH}/private.key" -out "${FILE_PATH}/cert.pem" -subj "/CN=bing.com"

    # Check whether chatGPT is unlocked
    if [ "$(check_chatgpt)" = 'unlock' ]; then
      CHAT_GPT_OUT_V4="direct"
      CHAT_GPT_OUT_V6="direct"
      NETFLIX_OUT_V6="direct"
    else
      CHAT_GPT_OUT_V4="wireguard-ipv4-only-out"
      CHAT_GPT_OUT_V6="wireguard-ipv6-prefer-out"
      NETFLIX_OUT_V6="wireguard-ipv6-prefer-out"
    fi

    if [[ ! "$SERVER_IP" =~ : ]]; then
      WARP_ENDPOINT=162.159.193.10
    else
      WARP_ENDPOINT=2606:4700:d0::a29f:c101
    fi

    cat > ${FILE_PATH}/sconf/inbound.json << ABC
{
    "log": {
        "disabled": false,
        "level": "info",
        "timestamp": true
    },
    "dns": {
        "servers": [
            {
                "tag": "google",
                "address": "tls://8.8.8.8"
            }
        ]
    },
    "inbounds": [
        {
            "type":"vless",
            "tag":"vless-in",
            "listen":"127.0.0.1",
            "listen_port": ${V_PORT},
            "sniff":true,
            "sniff_override_destination":true,
            "transport":{
                "type":"ws",
                "path":"/vless",
                "max_early_data":2048,
                "early_data_header_name":"Sec-WebSocket-Protocol"
            },
            "multiplex":{
                "enabled":true,
                "padding":true,
                "brutal":{
                    "enabled":true,
                    "up_mbps":1000,
                    "down_mbps":1000
                }
            },
            "users":[
                {
                    "uuid": "${UUID}",
                    "flow":""
                }
            ]
        }
    ]
}
ABC

    if [ -n "${HY2_PORT}" ]; then
      cat > ${FILE_PATH}/sconf/inbound_h.json << DEF
{
    "inbounds": [
        {
            "tag": "hysteria-in",
            "type": "hysteria2",
            "listen":"::",
            "listen_port": ${HY2_PORT},
            "users": [
                {
                    "password": "${UUID}"
                }
            ],
            "masquerade": "https://bing.com",
            "tls": {
                "enabled": true,
                "alpn": [
                    "h3"
                ],
                "certificate_path": "${FILE_PATH}/cert.pem",
                "key_path": "${FILE_PATH}/private.key"
            }
        }
    ]
}
DEF
    fi


    if [ -n "${TUIC_PORT}" ]; then
      cat > ${FILE_PATH}/sconf/inbound_t.json << GHI
{
    "inbounds": [
        {
            "tag": "tuic-in",
            "type": "tuic",
            "listen":"::",
            "listen_port": ${TUIC_PORT},
            "users": [
                {
                    "uuid": "${UUID}",
                    "password": "${tuicpass}"
                }
            ],
            "congestion_control": "bbr",
            "tls": {
                "enabled": true,
                "alpn": [
                    "h3"
                ],
                "certificate_path": "${FILE_PATH}/cert.pem",
                "key_path": "${FILE_PATH}/private.key"
            }
        }
    ]
}
GHI
    fi

    if [ -n "${REAL_PORT}" ]; then
      cat > ${FILE_PATH}/sconf/inbound_r.json << JKL
{
    "inbounds": [
        {
            "tag": "vless-reality-in",
            "type": "vless",
            "listen": "::",
            "listen_port": ${REAL_PORT},
            "users": [
                {
                    "uuid": "${UUID}",
                    "flow": "xtls-rprx-vision"
                }
            ],
            "tls": {
                "enabled": true,
                "server_name": "${SNI}",
                "reality": {
                    "enabled": true,
                    "handshake": {
                        "server": "${SNI}",
                        "server_port": 443
                    },
                    "private_key": "${private_key}",
                    "short_id": [
                        ""
                    ]
                }
            }
        }
    ]
}
JKL
    fi

    cat > ${FILE_PATH}/sconf/outbound.json << MNO
{
    "outbounds": [
        {
            "type": "direct",
            "tag": "direct"
        },
        {
            "type": "direct",
            "tag": "direct-ipv4-prefer-out",
            "domain_strategy": "prefer_ipv4"
        },
        {
            "type": "direct",
            "tag": "direct-ipv4-only-out",
            "domain_strategy": "ipv4_only"
        },
        {
            "type": "direct",
            "tag": "direct-ipv6-prefer-out",
            "domain_strategy": "prefer_ipv6"
        },
        {
            "type": "direct",
            "tag": "direct-ipv6-only-out",
            "domain_strategy": "ipv6_only"
        },
        {
            "type": "wireguard",
            "tag": "wireguard-out",
            "server": "${WARP_ENDPOINT}",
            "server_port": 2408,
            "local_address": [
                "172.16.0.2/32",
                "2606:4700:110:812a:4929:7d2a:af62:351c/128"
            ],
            "private_key": "gBthRjevHDGyV0KvYwYE52NIPy29sSrVr6rcQtYNcXA=",
            "peer_public_key": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
            "reserved": [
                6,
                146,
                6
            ]
        },
        {
            "type": "direct",
            "tag": "wireguard-ipv4-prefer-out",
            "detour": "wireguard-out",
            "domain_strategy": "prefer_ipv4"
        },
        {
            "type": "direct",
            "tag": "wireguard-ipv4-only-out",
            "detour": "wireguard-out",
            "domain_strategy": "ipv4_only"
        },
        {
            "type": "direct",
            "tag": "wireguard-ipv6-prefer-out",
            "detour": "wireguard-out",
            "domain_strategy": "prefer_ipv6"
        },
        {
            "type": "direct",
            "tag": "wireguard-ipv6-only-out",
            "detour": "wireguard-out",
            "domain_strategy": "ipv6_only"
        }
    ],
    "route": {
        "rule_set": [
            {
                "tag": "geosite-netflix",
                "type": "remote",
                "format": "binary",
                "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-netflix.srs",
                "update_interval": "1d"
            },
            {
                "tag": "geosite-openai",
                "type": "remote",
                "format": "binary",
                "url": "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/openai.srs",
                "update_interval": "1d"
            }
        ],
        "rules": [
            {
                "rule_set": [
                    "geosite-netflix"
                ],
                "outbound":"${NETFLIX_OUT_V6}"
            },
            {
                "domain":"api.openai.com",
                "outbound":"${CHAT_GPT_OUT_V4}"
            },
            {
                "rule_set":"geosite-openai",
                "outbound":"${CHAT_GPT_OUT_V6}"
            }
        ],
        "final": "direct"
    },
    "experimental": {
        "cache_file": {
        "path": "${FILE_PATH}/cache.db",
        "cache_id": "mycacheid",
        "store_fakeip": true
        }
    }
}
MNO
  }

  argo_type() {
    if [ -e "${FILE_PATH}/server" ] && [ -z "$ARGO_AUTH" ] && [ -z "$ARGO_DOMAIN" ]; then
      echo "ARGO_AUTH or ARGO_DOMAIN is empty, use Quick Tunnels" > /dev/null
      return
    fi

    if [ -e "${FILE_PATH}/server" ] && [ -n "$(echo "$ARGO_AUTH" | grep TunnelSecret)" ]; then
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

  if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_KEY}" ]; then
    nezhacfg() {
      tlsPorts=("443" "8443" "2096" "2087" "2083" "2053")
      case "$NEZHA_VERSION" in
        "V0" )
          if [[ " ${tlsPorts[@]} " =~ " ${NEZHA_PORT} " ]]; then
            NEZHA_TLS="--tls"
          else
            NEZHA_TLS=""
          fi
          ;;
        "V1" )
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
          ;;
      esac
    }
    nezhacfg
  fi

  generate_config
  argo_type
  args
}

# run
run_server() {
  ${FILE_PATH}/server $args > /dev/null 2>&1 &
}

run_web() {
  ${FILE_PATH}/web run -C ${FILE_PATH}/sconf > /dev/null 2>&1 &
}

run_npm() {
  if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_KEY}" ]; then
    case "$NEZHA_VERSION" in
      "V0" )
        ${FILE_PATH}/npm -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${NEZHA_TLS} > /dev/null 2>&1 &
        ;;
      "V1" )
        ${FILE_PATH}/npm -c ${FILE_PATH}/config.yml > /dev/null 2>&1 &
        ;;
    esac
  fi
}

keep_alive() {
  if [[ -e "${FILE_PATH}/server" && ! $(pidof server) ]]; then
    run_server
    sleep 5
    check_hostname_change && build_urls
    hint "server runs again !"
  fi
  sleep 5
  if [[ -e "${FILE_PATH}/web" && ! $(pidof web) ]]; then
    run_web
    hint "web runs again !"
  fi
  sleep 5
  if [[ -e "${FILE_PATH}/npm" && ! $(pidof npm) ]]; then
    run_npm
    hint "npm runs again !"
  fi
}

run_processes() {
  [ -e "${FILE_PATH}/server" ] && run_server
  sleep 5
  [ -e "${FILE_PATH}/web" ] && run_web
  [ -e "${FILE_PATH}/npm" ] && run_npm
  sleep 1

  check_hostname_change && build_urls && sleep 1

  if [ -n "$SUB_URL" ] && [ -e "${FILE_PATH}/up.sh" ]; then
    bash ${FILE_PATH}/up.sh > /dev/null 2>&1 &
  fi

  case "$openkeepalive" in
    "1" )
      while true
      do
      keep_alive
      sleep 50
      done
      ;;
  esac
}

# get IP and country
get_ip_country_code() {
  export SERVER_IP=$(curl -s https://speed.cloudflare.com/meta | tr ',' '\n' | grep -E '"clientIp"\s*:\s*"' | sed 's/.*"clientIp"\s*:\s*"\([^"]*\)".*/\1/')
  # export SERVER_IP=$(curl -s https://ipinfo.io/ip)
  # echo "${SERVER_IP}"

  if [[ "$SERVER_IP" =~ : ]]; then
    export MYIP="[$SERVER_IP]"
    # echo "ipv6_address：$MYIP"
  else
    export MYIP="$SERVER_IP"
    # echo "ipv4_address：$MYIP"
  fi

  export country_abbreviation=$(curl -s https://speed.cloudflare.com/meta | awk -F\" '{print $26"-"$18}' | sed -e 's/ /_/g')   # Display ISP and country abbreviation
  # export country_abbreviation=$(curl -s https://speed.cloudflare.com/meta | tr ',' '\n' | grep -E '"country"\s*:\s*"' | sed 's/.*"country"\s*:\s*"\([^"]*\)".*/\1/')   # Display country abbreviation
  # echo "${country_abbreviation}"
}

# check_hostname
check_hostname_change() {
  if [ -z "$ARGO_AUTH" ] && [ -z "$ARGO_DOMAIN" ]; then
    [ -s ${FILE_PATH}/boot.log ] && export ARGO_DOMAIN=$(cat ${FILE_PATH}/boot.log | grep -o "info.*https://.*trycloudflare.com" | sed "s@.*https://@@g" | tail -n 1)
    # [ -s ${FILE_PATH}/boot.log ] && export ARGO_DOMAIN=$(cat ${FILE_PATH}/boot.log | grep -o "https://.*trycloudflare.com" | tail -n 1 | sed 's/https:\/\///')
  fi
}

# build_urls
build_urls() {
  cat > ${FILE_PATH}/tmp.txt << ABC
vless://${UUID}@${CF_IP}:${CFPORT}?host=${ARGO_DOMAIN}&path=%2Fvless%3Fed%3D2048&type=ws&encryption=none&security=tls&sni=${ARGO_DOMAIN}#${country_abbreviation}-${SUB_NAME}
hysteria2://${UUID}@${MYIP}:${HY2_PORT}/?sni=www.bing.com&alpn=h3&insecure=1#${country_abbreviation}-${SUB_NAME}
tuic://${UUID}:${tuicpass}@${MYIP}:${TUIC_PORT}?sni=www.bing.com&congestion_control=bbr&udp_relay_mode=native&alpn=h3&allow_insecure=1#${country_abbreviation}-${SUB_NAME}
vless://${UUID}@${MYIP}:${REAL_PORT}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${SNI}&fp=chrome&pbk=${public_key}&type=tcp&headerType=none#${country_abbreviation}-${SUB_NAME}-realitytcp
ABC
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

tail -f /dev/null
