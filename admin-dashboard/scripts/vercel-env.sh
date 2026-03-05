#!/usr/bin/env bash
# Add Supabase env vars to Vercel (run from repo root or admin-dashboard).
# Requires: vercel CLI installed and logged in (npx vercel login).
#
# Usage:
#   ./scripts/vercel-env.sh
#     → Prompts for URL and key (no secrets in shell history)
#   ./scripts/vercel-env.sh "https://YOUR_PROJECT.supabase.co" "YOUR_ANON_KEY"
#     → Uses provided values (avoid if others can see your terminal)
#
# Get URL and key from: Supabase Dashboard → Project Settings → API

set -e
cd "$(dirname "$0")/.."

if [ -n "$1" ] && [ -n "$2" ]; then
  SUPABASE_URL="$1"
  SUPABASE_KEY="$2"
  echo "Using provided URL and key (production only)."
else
  echo "Enter your Supabase project URL (e.g. https://xxx.supabase.co):"
  read -r SUPABASE_URL
  echo "Enter your Supabase anon key:"
  read -r -s SUPABASE_KEY
  echo
fi

for env in production preview development; do
  echo "$SUPABASE_URL" | npx vercel env add NEXT_PUBLIC_SUPABASE_URL "$env"
  echo "$SUPABASE_KEY" | npx vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY "$env"
done

echo "Done. Redeploy for changes to take effect: npx vercel --prod"
echo "Pull env locally: npx vercel env pull .env.local"
