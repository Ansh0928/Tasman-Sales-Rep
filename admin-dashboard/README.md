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
3. **Environment variables**: In Project Settings → Environment Variables, add:
   - `NEXT_PUBLIC_SUPABASE_URL` = your Supabase project URL
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` = your Supabase anon (public) key
4. Deploy.

## Run locally

```bash
cd admin-dashboard
npm install
cp .env.example .env.local
# Edit .env.local with your Supabase URL and anon key
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).
