#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
AUTOMATION_REPO_ROOT="${AUTOMATION_REPO_ROOT:-${HOME}/code/Newsletter-automation}"
REMOTE_URL="${AUTOMATION_REMOTE_URL:-$(git -C "${SOURCE_REPO_ROOT}" remote get-url origin)}"

mkdir -p "$(dirname "${AUTOMATION_REPO_ROOT}")"

if [[ ! -d "${AUTOMATION_REPO_ROOT}/.git" ]]; then
  git clone "${REMOTE_URL}" "${AUTOMATION_REPO_ROOT}"
else
  git -C "${AUTOMATION_REPO_ROOT}" pull --rebase origin main
fi

chmod +x "${AUTOMATION_REPO_ROOT}/scripts/publish-daily-newsletter.sh"
if [[ -f "${AUTOMATION_REPO_ROOT}/scripts/run-scheduled-newsletter-publisher.sh" ]]; then
  chmod +x "${AUTOMATION_REPO_ROOT}/scripts/run-scheduled-newsletter-publisher.sh"
fi

echo "Automation clone ready:"
echo "  ${AUTOMATION_REPO_ROOT}"
