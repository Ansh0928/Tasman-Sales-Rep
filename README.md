# 📍 Tasman-Sales-Rep — iOS Sales Rep Visit Tracker + Admin Dashboard

> **Live (Admin Dashboard):** [https://tasman-sales-rep.vercel.app](https://tasman-sales-rep.vercel.app)
>
> A native **iOS app** (Swift/SwiftUI) for Tasman Star Seafoods sales representatives to log client visits on the go, paired with a **Next.js web dashboard** for admins to view all visit entries on an interactive map. Data syncs in real-time via **Supabase**.
>
> ---
>
> ## ✨ What It Does
>
> - **iOS Visit Logging** — Sales reps log visits with company name, contact person, notes, and GPS location
> - - **GPS Auto-Capture** — Automatically captures latitude/longitude when logging a visit
>   - - **Supabase Sync** — All visit data syncs to a PostgreSQL database via Supabase in real-time
>     - - **Admin Dashboard** — Web-based dashboard to view all visit entries on an interactive Leaflet map
>       - - **Map Visualization** — Interactive map with markers for each visit, showing company name and visit details
>         - - **Device Tracking** — Each visit is tagged with a device ID for multi-rep support
>           - - **Responsive Layout** — Admin dashboard works on desktop and mobile browsers
>            
>             - ---
>
> ## 🛠️ Tech Stack
>
> | Category | Technology |
> |----------|-----------|
> | iOS App | Swift, SwiftUI, Xcode |
> | Admin Dashboard | Next.js (App Router), TypeScript |
> | Database | Supabase (PostgreSQL + Auth + RLS) |
> | Maps | Leaflet.js (admin dashboard) |
> | Deployment | Vercel (admin dashboard) |
> | Location | CoreLocation (iOS GPS) |
>
> ---
>
> ## 📁 Project Structure
>
> ```
> ├── Tasman-Sales-Rep/              # iOS app (Swift/SwiftUI)
> │   ├── Tasman_Sales_RepApp.swift  # App entry point
> │   ├── ContentView.swift          # Main view
> │   └── ...                        # Models, views, services
> ├── Tasman-Sales-Rep.xcodeproj/    # Xcode project
> ├── admin-dashboard/               # Next.js admin web dashboard
> │   ├── src/app/                   # App Router pages
> │   ├── .env.example               # Environment variable template
> │   ├── scripts/
> │   │   └── vercel-env.sh          # Vercel env setup script
> │   └── package.json
> ├── admin-dashboard.html           # Standalone HTML dashboard (legacy)
> └── supabase-schema.sql            # Database schema for Supabase
> ```
>
> ---
>
> ## 🗃️ Database Schema
>
> The `visit_entries` table stores all visit data:
>
> | Column | Type | Description |
> |--------|------|-------------|
> | `id` | UUID | Primary key |
> | `company_name` | TEXT | Company visited |
> | `contact_person` | TEXT | Person met |
> | `latitude` | DOUBLE PRECISION | GPS latitude |
> | `longitude` | DOUBLE PRECISION | GPS longitude |
> | `notes` | TEXT | Visit notes |
> | `visit_date` | TIMESTAMPTZ | When the visit occurred |
> | `device_id` | TEXT | Device identifier |
>
> Row Level Security (RLS) is enabled — anon users can read and insert entries, service_role (iOS app) bypasses RLS.
>
> ---
>
> ## 🚀 Getting Started
>
> ### iOS App
>
> 1. Open `Tasman-Sales-Rep.xcodeproj` in Xcode
> 2. 2. Configure your Supabase URL and service role key in the app config
>    3. 3. Build and run on a device or simulator
>      
>       4. ### Admin Dashboard
>      
>       5. ```bash
>          cd admin-dashboard
>
>          # Install dependencies
>          npm install
>
>          # Set up environment variables
>          cp .env.example .env.local
>          # Edit .env.local with your Supabase URL and anon key
>          # (Supabase Dashboard → Project Settings → API)
>
>          # Run development server
>          npm run dev
>          ```
>
> Open [http://localhost:3000](http://localhost:3000) to view the dashboard.
>
> ### Environment Variables (Admin Dashboard)
>
> ```
> NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
> NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_ANON_KEY
> ```
>
> ### Deploy Admin Dashboard to Vercel
>
> 1. Import this repo in Vercel
> 2. 2. Set **Root Directory** to `admin-dashboard` in Project Settings → General
>    3. 3. Add environment variables (`NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`)
>       4. 4. Deploy
>         
>          5. ---
>         
>          6. ## 🚢 Deployment
>         
>          7. - **Admin Dashboard** deployed on **Vercel** with root directory set to `admin-dashboard`
> - **iOS App** built and deployed via Xcode / TestFlight
>
> - **Live URL:** [https://tasman-sales-rep.vercel.app](https://tasman-sales-rep.vercel.app)
>
> - ---
>
> ## 🔗 Related Tasman Projects
>
> | Project | Description | Link |
> |---------|------------|------|
> | [TASMAN-STAR](https://github.com/Ansh0928/TASMAN-STAR) | Customer-facing storefront (Shopify Storefront API) | [tasman-star.vercel.app](https://tasman-star.vercel.app) |
> | [TASMAN-ADMIN](https://github.com/Ansh0928/TASMAN-ADMIN) | Full admin panel + e-commerce backend | [tasman-admin.vercel.app](https://tasman-admin.vercel.app) |
> | [TASMAN-STAR-transport](https://github.com/Ansh0928/TASMAN-STAR-transport) | Freight/transport booking app (mobile + admin web) | [tasman-transport-admin.vercel.app](https://tasman-transport-admin.vercel.app) |
> | [tasmanstarseafoodmarket](https://github.com/Ansh0928/tasmanstarseafoodmarket) | Marketing website (React + Vite) with product showcase | — |
>
> ---
>
> ## 📄 License
>
> MIT
