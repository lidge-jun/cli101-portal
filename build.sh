#!/usr/bin/env bash
set -eo pipefail

CODEX="/Users/jun/Developer/codex"
PORTAL="/Users/jun/Developer/cli101-portal"

SLUGS=(aider codex-cli gemini-cli opencode opencode-current claude-code copilot-cli antigravity hermes lazycodex superpowers omc omx omo)
RELS=(
  "110_aider/website"
  "120_codex-cli/website"
  "130_gemini-cli/website"
  "140_opencode/website"
  "141_opencode-current/website"
  "150_claude_code/website"
  "151_copilot_cli/website"
  "152_antigravity/website"
  "160_hermes-agent/cli101"
  "161_lazycodex/website"
  "162_superpowers/website"
  "170_oh-my-claudecode/website"
  "171_oh-my-codex/website"
  "172_oh-my-openagent/website"
)

mkdir -p "$PORTAL/sites"

FAIL=0
for i in "${!SLUGS[@]}"; do
  slug="${SLUGS[$i]}"
  rel="${RELS[$i]}"
  dir="$CODEX/$rel"
  conf="$dir/next.config.ts"
  echo "== Building $slug ($rel) =="

  cp "$conf" "$conf.bak"

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

  if (cd "$dir" && pnpm build > /tmp/cli101-build-$slug.log 2>&1); then
    rm -rf "$PORTAL/sites/$slug"
    cp -r "$dir/out" "$PORTAL/sites/$slug"
    echo "  OK → sites/$slug/"
  else
    echo "  FAIL (see /tmp/cli101-build-$slug.log)"
    FAIL=1
  fi

  mv "$conf.bak" "$conf"
done

if [ $FAIL -eq 0 ]; then
  echo ""
  echo "All 14 sites built successfully!"
else
  echo ""
  echo "Some builds failed. Check logs."
  exit 1
fi
