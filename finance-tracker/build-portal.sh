#!/usr/bin/env bash
# Generates functions/portal/html.ts from index.html, substituting the
# Supabase project URL and publishable (anon) key. Run before deploying the
# "portal" edge function.
set -euo pipefail
cd "$(dirname "$0")"
: "${SUPABASE_URL:?set SUPABASE_URL}" "${SUPABASE_ANON_KEY:?set SUPABASE_ANON_KEY}"
b64=$(sed -e "s|__SUPABASE_URL__|${SUPABASE_URL}|" \
          -e "s|__SUPABASE_ANON_KEY__|${SUPABASE_ANON_KEY}|" index.html | base64 -w0)
printf 'export const HTML_B64 = "%s";\n' "$b64" > functions/portal/html.ts
echo "Wrote functions/portal/html.ts ($(wc -c < functions/portal/html.ts) bytes)"
