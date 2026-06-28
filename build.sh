#!/usr/bin/env bash
set -euo pipefail

CODEX="/Users/jun/Developer/codex"
PORTAL="/Users/jun/Developer/cli101-portal"

declare -A SITES=(
  [aider]="110_aider/website"
  [codex-cli]="120_codex-cli/website"
  [gemini-cli]="130_gemini-cli/website"
  [opencode]="140_opencode/website"
  [opencode-current]="141_opencode-current/website"
  [claude-code]="150_claude_code/website"
  [copilot-cli]="151_copilot_cli/website"
  [antigravity]="152_antigravity/website"
  [hermes]="160_hermes-agent/cli101"
  [lazycodex]="161_lazycodex/website"
  [superpowers]="162_superpowers/website"
  [omc]="170_oh-my-claudecode/website"
  [omx]="171_oh-my-codex/website"
  [omo]="172_oh-my-openagent/website"
)

mkdir -p "$PORTAL/sites"

FAIL=0
for slug in "${!SITES[@]}"; do
  rel="${SITES[$slug]}"
  dir="$CODEX/$rel"
  conf="$dir/next.config.ts"
  echo "== Building $slug ($rel) =="

  # Backup original config
  cp "$conf" "$conf.bak"

  # Patch: add output:'export' + basePath
  cat > "$conf" <<EOF
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  output: "export",
  basePath: "/sites/$slug",
  images: { unoptimized: true },
};

export default nextConfig;
EOF

  # Build
  if (cd "$dir" && pnpm build > /tmp/cli101-build-$slug.log 2>&1); then
    # Copy output
    rm -rf "$PORTAL/sites/$slug"
    cp -r "$dir/out" "$PORTAL/sites/$slug"
    echo "  OK → sites/$slug/"
  else
    echo "  FAIL (see /tmp/cli101-build-$slug.log)"
    FAIL=1
  fi

  # Restore original config
  mv "$conf.bak" "$conf"
done

if [ $FAIL -eq 0 ]; then
  echo ""
  echo "✅ All sites built successfully!"
  echo "Preview: cd $PORTAL && npx serve ."
else
  echo ""
  echo "❌ Some builds failed. Check logs."
  exit 1
fi
