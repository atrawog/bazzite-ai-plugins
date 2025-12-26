#!/usr/bin/env bash
# Helper: Check overlay testing session status
# Usage: ./check-overlay-status.sh
# Output: JSON with status information

set -euo pipefail

# Determine OS type and overlay status
if [[ -f /run/ostree-booted ]]; then
    OS_TYPE="immutable"

    if rpm-ostree status 2>/dev/null | grep -q "Unlocked:"; then
        OVERLAY_ACTIVE="true"
        STATUS="active"
    else
        OVERLAY_ACTIVE="false"
        STATUS="inactive"
    fi
else
    OS_TYPE="traditional"

    if [[ -L "/usr/share/bazzite-ai/just" ]]; then
        OVERLAY_ACTIVE="true"
        STATUS="active"
        SYMLINK_TARGET=$(readlink -f "/usr/share/bazzite-ai/just" 2>/dev/null || echo "unknown")
    else
        OVERLAY_ACTIVE="false"
        STATUS="inactive"
        SYMLINK_TARGET=""
    fi
fi

# Output JSON
cat <<EOF
{
  "os_type": "$OS_TYPE",
  "overlay_active": $OVERLAY_ACTIVE,
  "status": "$STATUS",
  "symlink_target": "${SYMLINK_TARGET:-null}"
}
EOF
