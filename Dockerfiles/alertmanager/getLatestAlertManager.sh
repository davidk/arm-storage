#!/bin/bash
# Get the latest alertmanager release and repack it into a Dockerfile
# Used for distributions/arches that alertmanager doesn't provide a Dockerfile for.
#
# Utilites Required
# - jq
# - curl

set -fue
set -o pipefail

RELEASE_LIST_URL="https://api.github.com/repos/prometheus/alertmanager/releases"
LATEST_RELEASE_URL="${RELEASE_LIST_URL}/latest"

if [[ $# -lt 3 ]]; then

  echo "usage: $0 [ windows | openbsd | netbsd | linux | freebsd | darwin | dragonfly ] [ armv5 | armv6 | armv7 ] [ latest | tag ] [ external-url ]"
  echo
  echo "example (latest): $0 linux armv7 latest example.com"
  echo "example (tagged): $0 linux armv5 v0.7.0 example.com"
  exit 1

fi

DIST=$1
ARCH=$2
RELEASE=$3
EXT_URL=$4

if [[ "${RELEASE}" == "latest" ]]; then
  RELEASE_INFO=$(curl -SsL ${LATEST_RELEASE_URL})
else
  RELEASE_INFO=$(curl -SsL ${RELEASE_LIST_URL}/tags/${RELEASE})
fi

echo "Building Dockerfile for ${DIST} (ver ${RELEASE} on arch ${ARCH}).."

DL_LINK=$(echo "${RELEASE_INFO}" | jq -r ".assets[] | .browser_download_url | select(test(\"alertmanager-.+.${DIST}-${ARCH}.tar.gz\"))")

TAG_REL=$(echo "${RELEASE_INFO}" | jq -r ".tag_name | select(test(\"^v[0-9].*[0-9]$\"))")

if [[ -z "${TAG_REL}" || -z "${DL_LINK}" ]]; then
  echo "Unable to get download link or tag version. Will not continue."
  echo
  echo "Tag output: ${TAG_REL}"
  echo "Download link output: ${DL_LINK}"
  echo
  echo "Exiting."
  exit 1
fi

echo "Tag version: ${TAG_REL}"
echo "Fetching from: ${DL_LINK}"

T_DIR=$(readlink -f .)

echo "Writing Dockerfile: ${T_DIR}/Dockerfile"

cat << EOF > ${T_DIR}/Dockerfile

FROM resin/armhf-alpine:3.4

RUN apk update && apk add curl && curl -SL -\# ${DL_LINK} > /alertmanager.tar.gz \\
EOF

cat <<"EOF" >>${T_DIR}/Dockerfile
&& TARGET=$(tar -xvf /alertmanager.tar.gz) \
&& EXT_DIR=$(echo ${TARGET} | cut -d'/' -f1) \
&& cd ${EXT_DIR} \
&& cp alertmanager /bin/ \
&& mkdir -p /etc/alertmanager \
&& cp simple.yml /etc/alertmanager/config.yml \
&& rm -rf /${EXT_DIR} /alertmanager.tar.gz

EXPOSE     9093
VOLUME     [ "/alertmanager" ]
WORKDIR    /alertmanager
ENTRYPOINT [ "/bin/alertmanager" ]
CMD        [ "-config.file=/etc/alertmanager/config.yml", \
EOF

cat << EOF >>${T_DIR}/Dockerfile
	         "-web.external-url=${EXT_URL}", \\
             "-storage.path=/alertmanager" ]
EOF
echo "Finished writing Dockerfile. To build, run docker build -t alertmanager . "