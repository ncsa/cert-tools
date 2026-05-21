#!/usr/bin/bash

# first name in the list will be the CN
NAMES_1=(
  ldap-1.ncsa.illinois.edu
  isf-ldap-01.ncsa.illinois.edu
  isf-ldap-02.ncsa.illinois.edu
)

NAMES_2=(
  ldap-2.ncsa.illinois.edu
  isf-ldap-05.ncsa.illinois.edu
  isf-ldap-06.ncsa.illinois.edu
)



mk_config() {
  set -x
  local _hostnames _firstname _out_fn
  declare -n _hostnames="$1"
  _firstname="${_hostnames}"
  _out_fn="${_firstname}".cfg
  rm -f "${_out_fn}"
  cat <<ENDHERE >"${_out_fn}"
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[ v3_req ]
# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[ req_distinguished_name ]
C                      = US
ST                     = Illinois
L                      = Urbana
O                      = University of Illinois
OU                     = NCSA
CN                     = ${_firstname}
emailAddress           = ldap-admin@lists.ncsa.illinois.edu

[alt_names]
ENDHERE

#add alt_names
for i in "${!_hostnames[@]}"; do
  hostname="${_hostnames[$i]}"
  echo DNS.$i = "${hostname}" >> "${_out_fn}"
done
echo "${_out_fn}"
}


mk_key() {
  set -x
  local _hostnames _firstname _out_fn
  declare -n _hostnames="$1"
  _firstname="${_hostnames}"
  _out_fn="${_firstname}".key.pem
  rm -f "${_out_fn}"
  # openssl genrsa \
  #   -out "${_out_fn}" \
    # 4096
  openssl ecparam \
    -out "${_out_fn}" \
    -name prime256v1 \
    -genkey
  echo "${_out_fn}"
}


mk_csr() {
  local _hostnames _firstname _out_fn _key_fn _cfg_fn
  declare -n _hostnames="$1"
  _firstname="${_hostnames}"
  _out_fn="${_firstname}".csr
  _key_fn=$( mk_key "${1}" )
  _cfg_fn=$( mk_config "${1}" )
  openssl req \
    -new \
    -out "${_out_fn}" \
    -key "${_key_fn}" \
    -config "${_cfg_fn}"
}

###
# MAIN
###

mk_csr NAMES_1
mk_csr NAMES_2
