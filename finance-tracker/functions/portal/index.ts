// Serves the Finance Tracker single-page portal.
// html.ts is generated from ../../index.html by ../../build-portal.sh — do not edit it by hand.
import { HTML } from "./html.ts";

Deno.serve(() =>
  new Response(HTML, {
    headers: {
      "content-type": "text/html; charset=utf-8",
      "cache-control": "no-cache",
    },
  })
);
