#!/usr/bin/env bash
# Generates functions/portal/html.ts from index.html, substituting the
# Supabase project URL and publishable (anon) key. Run before deploying the
# "portal" edge function.
set -euo pipefail
cd "$(dirname "$0")"
: "${SUPABASE_URL:?set SUPABASE_URL}" "${SUPABASE_ANON_KEY:?set SUPABASE_ANON_KEY}"
SUPABASE_URL="$SUPABASE_URL" SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" python3 - <<'EOF'
import os
html = open('index.html').read()
html = html.replace('__SUPABASE_URL__', os.environ['SUPABASE_URL'])
html = html.replace('__SUPABASE_ANON_KEY__', os.environ['SUPABASE_ANON_KEY'])
# escape for a JS template literal
html = html.replace('\\', '\\\\').replace('`', '\\`').replace('${', '\\${')
with open('functions/portal/html.ts', 'w') as f:
    f.write('export const HTML = `' + html + '`;\n')
EOF
echo "Wrote functions/portal/html.ts ($(wc -c < functions/portal/html.ts) bytes)"
