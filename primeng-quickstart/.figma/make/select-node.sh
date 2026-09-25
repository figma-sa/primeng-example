#!/usr/bin/env bash
# Sourced helper: put a Node.js compatible with the Angular 22 CLI on PATH.
# The CLI requires ^22.22.3 || ^24.15.0 || >=26. The host's default Node may be
# older, so scan nvm's installed versions and prepend the first match to PATH.

# Returns 0 if "$1" (a plain X.Y.Z string) satisfies the Angular engine range.
_node_ok() {
  local v="${1#v}" major minor patch
  IFS=. read -r major minor patch <<<"$v"
  major=${major:-0}; minor=${minor:-0}; patch=${patch:-0}
  if [ "$major" -ge 26 ]; then return 0; fi
  if [ "$major" -eq 24 ]; then
    [ "$minor" -gt 15 ] && return 0
    [ "$minor" -eq 15 ] && [ "$patch" -ge 0 ] && return 0
  fi
  if [ "$major" -eq 22 ]; then
    [ "$minor" -gt 22 ] && return 0
    [ "$minor" -eq 22 ] && [ "$patch" -ge 3 ] && return 0
  fi
  return 1
}

ensure_node() {
  # Already good? Nothing to do.
  if command -v node >/dev/null 2>&1 && _node_ok "$(node -v)"; then
    return 0
  fi

  local nvm_dir="${NVM_DIR:-$HOME/.nvm}" dir ver
  if [ -d "$nvm_dir/versions/node" ]; then
    # Prefer the highest qualifying version.
    for dir in $(ls -1 "$nvm_dir/versions/node" 2>/dev/null | sort -Vr); do
      ver="${dir#v}"
      if [ -x "$nvm_dir/versions/node/$dir/bin/node" ] && _node_ok "$ver"; then
        export PATH="$nvm_dir/versions/node/$dir/bin:$PATH"
        return 0
      fi
    done
  fi

  echo "select-node: WARNING no Node matching ^22.22.3 || ^24.15.0 || >=26 found; using $(node -v 2>/dev/null || echo none)" >&2
  return 0
}
