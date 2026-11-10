#!/bin/sh
# Builds the standalone site from src/page.html:
#   index.html          – open locally
#   site/               – upload this folder to free hosting (Netlify Drop etc.)
# src/page.html itself is what gets published as the Claude page.
cd "$(dirname "$0")"
ICON="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ctext y='.9em' font-size='90'%3E%F0%9F%8D%B0%3C/text%3E%3C/svg%3E"
{ printf '<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">\n'
  printf '<meta name="theme-color" content="#ffc4dc">\n<meta name="apple-mobile-web-app-capable" content="yes">\n<meta name="mobile-web-app-capable" content="yes">\n<meta name="apple-mobile-web-app-title" content="Anje'"'"'s Recipes">\n'
  printf '<meta name="robots" content="noindex, nofollow">\n<link rel="icon" href="%s">\n<link rel="apple-touch-icon" href="icon-192.png">\n<link rel="manifest" href="manifest.webmanifest">\n</head>\n<body>\n' "$ICON"
  cat src/page.html
  printf '\n</body>\n</html>\n'; } > index.html
sed "s/__VERSION__/$(date +%Y%m%d%H%M%S)/" src/sw.js > sw.js
rm -rf site && mkdir -p site/photos && cp index.html sw.js manifest.webmanifest icon-192.png icon-512.png site/ && cp photos/*.jpg site/photos/
printf 'User-agent: *\nDisallow: /\n' > site/robots.txt
echo "built index.html and site/"
