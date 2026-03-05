# Tasman Sales Rep – Admin Dashboard

Next.js admin dashboard for viewing sales rep visit entries (Supabase).

## Setup (Supabase keys)

1. Copy `.env.example` to `.env.local`:
   ```bash
   cp .env.example .env.local
   ```
2. Edit `.env.local` and set your Supabase URL and anon key (Supabase Dashboard → Project Settings → API).

## Deploy on Vercel

1. **Import** this repo in [Vercel](https://vercel.com).
2. **Set Root Directory**: In Project Settings → General → **Root Directory**, set it to **`admin-dashboard`**.
3. **Environment variables** (choose one):

   **Option A – Vercel CLI** (run in your terminal):
   ```bash
   cd admin-dashboard
   npx vercel login
   npx vercel link
   ./scripts/vercel-env.sh
   ```
   When prompted, paste your Supabase URL and anon key. Then redeploy: `npx vercel --prod`.

   **Option B – One-off with value** (replace placeholders):
   ```bash
   echo "https://YOUR_PROJECT.supabase.co" | npx vercel env add NEXT_PUBLIC_SUPABASE_URL production
   echo "YOUR_ANON_KEY" | npx vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
   ```

   **Option C – Dashboard**: Project Settings → Environment Variables in the Vercel UI.

4. Deploy (or redeploy so new env vars apply).

## Run locally

```bash
cd admin-dashboard
npm install
cp .env.example .env.local
# Edit .env.local with your Supabase URL and anon key
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

### Quick test locally

1. `cp .env.example .env.local`
2. Edit `.env.local` with your Supabase URL and anon key (Supabase Dashboard → Project Settings → API)
3. `npm run dev`
