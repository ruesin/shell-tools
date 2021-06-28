#!/usr/bin/env bash

GIT_PUSHER_VERSION="1.0.0"

CURRENT_SCRIPT_DIR=$(cd $(dirname $0); pwd)

CURRENT_WORKER_DIR=$(pwd)

echo $CURRENT_WORKER_DIR

# GIT_PUSHER__FOLDER_NAME="${CURRENT_WORKER_DIR}/.sin_git_pusher/${GIT_PUSHER_VERSION}/"
GIT_PUSHER__FOLDER_NAME="${CURRENT_WORKER_DIR}/.sin_git_pusher/"

# 在工作目录下是否有记录文件 ./.sin_git_pusher/
# 在用户目录下是否有记录文件
# 在临时目录下是否有记录文件
if [ ! -d "${GIT_PUSHER__FOLDER_NAME}" ]; then
    mkdir -p "${GIT_PUSHER__FOLDER_NAME}"
fi

if [ ! -f "${GIT_PUSHER__FOLDER_NAME}.gitignore" ];then
    echo "*" > "${GIT_PUSHER__FOLDER_NAME}.gitignore"
fi

GIT_PUSHER_CONFIG_FILE="${GIT_PUSHER__FOLDER_NAME}config"

if [ ! -f "${GIT_PUSHER_CONFIG_FILE}" ];then
    touch "${GIT_PUSHER_CONFIG_FILE}"
fi

# PUSH

usage() {
    echo 'NAME'
    echo 'git-pusher -- Batch push git repositories.'
    echo ''
    echo 'SYNOPSIS'
    echo 'git-pusher [-a] [-d] [-l]'
    echo ''
    echo 'DESCRIPTION'
    echo 'Batch push git repositories.'
    echo ''
    echo 'The options are as follows:'
    echo '  -p    [default] Push to remote.'
    echo '  -a '
    echo '        Add config.'
    echo '  -d '
    echo '        Delete config.'
    echo '  -l'
    echo '        List configs.'
    echo '  -h    show help'
    echo '  -v    show version'
}

gpAddRemote() {
    name=""
    while [ ${#name} -eq 0 ]
    do
        echo -n " alias: "
        read -r name
        done

    url=""
    while [ ${#url} -eq 0 ]
    do
        echo -n " url: "
        read -r url
        done

    echo "v${GIT_PUSHER_VERSION},${name},${url}" >> "$GIT_PUSHER_CONFIG_FILE"
    exit 0;
}

gpRemoteList() {
    # content=$(cat "${GIT_PUSHER_CONFIG_FILE}")
    # content=${content##*@@@}
    cat ${GIT_PUSHER_CONFIG_FILE} | while read -r line
    do
      if [ ${#line} -ge 10 ]; then
        name=$(echo -n "${line}" | cut -d "," -f 2)
        url=$(echo -n "${line}" | cut -d "," -f 3)
        # url=$(echo -n "${line}" | cut -d "," -f3)
        echo "- ${name}: ${url}"
      fi
    done
}

gpDeleteRemote() {
    n=""
    while [ ${#n} -eq 0 ]
    do
        echo -n " delete alias: "
        read -r n
        done

    temp_config_file=${GIT_PUSHER_CONFIG_FILE}".temp"
    rm -rf "${temp_config_file}" && touch "${temp_config_file}"

    cat < "${GIT_PUSHER_CONFIG_FILE}" | while read -r line
    do
      name=$(echo -n "${line}" | cut -d "," -f 2)
      if [ ${#line} -ge 10 ]; then
        if [ "${name}" != "${n}" ]; then
          echo "${line}" >> "$temp_config_file"
        fi
      fi
    done

    cat "${temp_config_file}" > "${GIT_PUSHER_CONFIG_FILE}"
    rm -rf "${temp_config_file}"

}

gpPush() {
    cat "${GIT_PUSHER_CONFIG_FILE}" | while read -r line
    do
      if [ ${#line} -ge 10 ]; then
        name=$(echo -n "${line}" | cut -d "," -f 2)
        url=$(echo -n "${line}" | cut -d "," -f 3)
        echo "Start push ${name} ..."
        git remote set-url origin "${url}" && git push
        #git remote set-url --add "${name}" "${url}" && git push "${name}"
      fi
    done
}

while getopts "a d l v h" opt
do
    case $opt in
        a) gpAddRemote && exit 0 ;;
        d) gpDeleteRemote && exit 0 ;;
        l) gpRemoteList && exit 0 ;;
        v) echo $GIT_PUSHER_VERSION ;;
        h) usage && exit 0 ;;
        ?) usage && exit 0 ;;
    esac
done

gpPush

exit 0