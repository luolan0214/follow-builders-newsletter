#!/usr/bin/env bash

set -euo pipefail

github_origin_url() {
  git -C "${REPO_ROOT}" remote get-url origin
}

github_owner_repo() {
  local remote_url owner_repo
  remote_url="$(github_origin_url)"

  if [[ "${remote_url}" =~ ^https://[^/]+/([^/]+/[^/.]+)(\.git)?$ ]]; then
    owner_repo="${BASH_REMATCH[1]}"
    printf '%s\n' "${owner_repo}"
    return 0
  fi

  if [[ "${remote_url}" =~ ^git@[^:]+:([^/]+/[^/.]+)(\.git)?$ ]]; then
    owner_repo="${BASH_REMATCH[1]}"
    printf '%s\n' "${owner_repo}"
    return 0
  fi

  echo "Unsupported origin remote URL: ${remote_url}" >&2
  return 1
}

github_push_user() {
  if [[ -n "${GITHUB_PUSH_USER:-}" ]]; then
    printf '%s\n' "${GITHUB_PUSH_USER}"
    return 0
  fi

  local owner_repo
  owner_repo="$(github_owner_repo)"
  printf '%s\n' "${owner_repo%%/*}"
}

github_push_token() {
  if [[ -n "${GITHUB_PUSH_TOKEN:-}" ]]; then
    printf '%s\n' "${GITHUB_PUSH_TOKEN}"
    return 0
  fi

  if ! command -v gh >/dev/null 2>&1; then
    echo "gh CLI is required for authenticated GitHub operations" >&2
    return 1
  fi

  gh auth token --hostname github.com --user "$(github_push_user)"
}

github_authenticated_remote() {
  local owner_repo token
  owner_repo="$(github_owner_repo)"
  token="$(github_push_token)"
  printf 'https://x-access-token:%s@github.com/%s.git\n' "${token}" "${owner_repo}"
}

git_authenticated_pull_rebase_main() {
  local auth_remote
  auth_remote="$(github_authenticated_remote)"

  git -C "${REPO_ROOT}" \
    -c credential.helper= \
    -c core.askPass= \
    -c credential.interactive=never \
    fetch "${auth_remote}" main:refs/remotes/origin/main

  git -C "${REPO_ROOT}" rebase origin/main
}

git_authenticated_push_main() {
  local auth_remote
  auth_remote="$(github_authenticated_remote)"

  git -C "${REPO_ROOT}" \
    -c credential.helper= \
    -c core.askPass= \
    -c credential.interactive=never \
    push "${auth_remote}" HEAD:main
}
