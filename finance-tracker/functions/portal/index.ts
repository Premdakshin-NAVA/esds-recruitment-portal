// Serves the Finance Tracker single-page portal.
// html.ts is generated from ../../index.html by ../../build-portal.sh — do not edit it by hand.
import { HTML_B64 } from "./html.ts";

const html = new TextDecoder().decode(
  Uint8Array.from(atob(HTML_B64), (c) => c.charCodeAt(0)),
);

Deno.serve(() =>
  new Response(html, {
    headers: {
      "content-type": "text/html; charset=utf-8",
      "cache-control": "no-cache",
    },
  })
);
