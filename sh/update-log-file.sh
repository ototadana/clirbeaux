#!/bin/bash
set -e

log() {
    git log --reverse --date=iso --pretty="===%h;%ad;%ae" --no-merges -U0 $1 \
        |grep -v -e '^diff ' -e '^new file ' -e '^index ' -e '^@@ ' -e '^--- ' -e '^$'
}

PROJECT_NAME="$1"
PROJECT_URL="$2"
BRANCH="$3"

BASE_DIR=$(cd $(dirname $0)/..; pwd)
PROJECT_DIR=${BASE_DIR}/tmp/${PROJECT_NAME}
REPO_DIR=${PROJECT_DIR}/repo
LAST_COMMIT_FILE=${PROJECT_DIR}/last-commit.txt
LOG_FILE=${PROJECT_DIR}/log.txt

mkdir -p "${PROJECT_DIR}"

if [ ! -d "${REPO_DIR}" ]; then
    git clone "${PROJECT_URL}" "${REPO_DIR}"
fi

cd "${REPO_DIR}"
git fetch
git reset --hard origin/${BRANCH}
LAST_COMMIT=$(git log -n 1 --format=%h)

if [ -f "${LAST_COMMIT_FILE}" ]; then
    PREVIOUS_COMMIT=$(cat "${LAST_COMMIT_FILE}")
else
    PREVIOUS_COMMIT=""
fi

if [ "${PREVIOUS_COMMIT}" == "${LAST_COMMIT}" ]; then
    exit 0
fi

if [ -z "${PREVIOUS_COMMIT}" ]; then
    log "" > "${LOG_FILE}"
else
    log ${PREVIOUS_COMMIT}...HEAD >> "${LOG_FILE}"
fi


echo ${LAST_COMMIT} > "${LAST_COMMIT_FILE}"
exit 0
