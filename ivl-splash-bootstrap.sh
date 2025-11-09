#!/usr/bin/env bash
set -euo pipefail

# IV League single-file bootstrap (Splash + Login)
# Usage:
#   1) Add this file to an empty GitHub repo as ivl-splash-bootstrap.sh
#   2) (Recommended) Upload your crest to public/iv-league-logo.png
#   3) Run in Codespaces or locally: bash ivl-splash-bootstrap.sh
#      It will scaffold a Next.js app with a splash screen and a /login page.

if [ -e package.json ]; then
  echo "Looks like files already exist here. Aborting to avoid overwrite." >&2
  exit 1
fi

mkdir -p src/app/api/leaderboard src/app/login src/app src/components src/lib public

# ----- package & config -----
cat > package.json << 'PKG'
{
  "name": "iv-league",
  "private": true,
  "version": "0.1.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "14.2.5",
    "react": "18.2.0",
    "react-dom": "18.2.0"
  },
  "devDependencies": {
    "autoprefixer": "^10.4.17",
    "postcss": "^8.4.35",
    "tailwindcss": "^3.4.3",
    "typescript": "5.3.3"
  }
}
PKG

cat > next.config.mjs << 'NEXTCFG'
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: { appDir: true }
}
export default nextConfig
NEXTCFG

cat > tsconfig.json << 'TSCFG'
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": false,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
TSCFG

cat > tailwind.config.ts << 'TWCFG'
import type { Config } from 'tailwindcss'
export default <Config>{
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        ivy: { 50:'#f3f6f3',100:'#e3ebe3',200:'#c1d3c2',300:'#97b398',400:'#69956a',500:'#3e7741',600:'#2f5c33',700:'#234528',800:'#18301b',900:'#0e1c10' },
        gold: { 400:'#d4af37',500:'#bfa12f',600:'#9f8727' },
        crimson: '#8C1D18', royal: '#27408B', purple: '#4B2E83'
      },
      fontFamily: { serif: ['EB Garamond', 'Georgia', 'serif'] },
      keyframes: {
        'fade-in-scale': {
          '0%':   { opacity: '0', transform: 'scale(0.96)' },
          '60%':  { opacity: '1', transform: 'scale(1.02)' },
          '100%': { opacity: '1', transform: 'scale(1)' }
        },
        'fade-in': { '0%': { opacity: '0' }, '100%': { opacity: '1' } }
      },
      animation: {
        'fade-in-scale': 'fade-in-scale 1200ms ease-out forwards',
        'fade-in': 'fade-in 800ms ease-out forwards'
      }
    }
  },
  plugins: []
}
TWCFG

cat > postcss.config.js << 'POSTCSS'
module.exports = { plugins: { tailwindcss: {}, autoprefixer: {} } }
POSTCSS

cat > next-env.d.ts << 'NXTENV'
/// <reference types="next" />
/// <reference types="next/image-types/global" />
// NOTE: This file should not be edited
NXTENV

cat > README.md << 'README'
# IV League (Splash + Login bootstrap)

## Run (Codespaces or local)
bash ivl-splash-bootstrap.sh
npm install
npm run dev

- Put your crest at: public/iv-league-logo.png
- Splash page fades the crest in and routes to /login
README

# ----- styles & layout -----
cat > src/app/globals.css << 'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root { --bg: #0e1c10; --fg: #f3f6f3; }
body { @apply bg-ivy-900 text-ivy-50 font-serif; }
.card { @apply bg-ivy-800/70 border border-gold-600 rounded-lg shadow-lg; }
.h1 { @apply text-3xl md:text-4xl font-semibold tracking-wide text-gold-400; }
.link { @apply text-gold-400 hover:text-gold-500 underline; }
CSS

cat > src/app/layout.tsx << 'LAYOUT'
import './globals.css'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'IV League',
  description: 'Compete by House. Win trophies. Master the markets.',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        {children}
      </body>
    </html>
  )
}
LAYOUT

# ----- Splash page -----
cat > src/app/page.tsx << 'SPLASH'
'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import Image from 'next/image'

export default function Splash() {
  const router = useRouter()
  useEffect(() => {
    const t = setTimeout(() => router.push('/login'), 1800)
    return () => clearTimeout(t)
  }, [router])

  return (
    <main className="min-h-screen grid place-items-center relative overflow-hidden">
      {/* Subtle vignette */}
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_center,rgba(255,255,255,0.06)_0%,rgba(0,0,0,0)_60%)]" />
      <div className="pointer-events-none absolute inset-0" style={{
        backgroundImage: 'linear-gradient(180deg, rgba(255,255,255,0.04), rgba(0,0,0,0))'
      }} />
      {/* Crest with fade/scale animation */}
      <div className="motion-reduce:animate-none animate-fade-in-scale">
        /iv-league-logo.png
      </div>
      <p
        className="mt-6 text-ivy-200/80 absolute bottom-10 text-sm motion-reduce:hidden animate-fade-in"
        style={{ animationDelay: '900ms' }}
      >
        Entering the IV League…
      </p>
    </main>
  )
}
SPLASH

# ----- Login page -----
cat > src/app/login/page.tsx << 'LOGIN'
'use client'

import { useState } from 'react'
import Image from 'next/image'
import Link from 'next/link'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [pwd, setPwd] = useState('')

  const onSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // TODO: replace with real auth (NextAuth/Clerk)
    alert(\`Logging in as \${email}\`)
  }

  return (
    <main className="min-h-screen grid place-items-center">
      <div className="w-full max-w-md">
        <div className="flex justify-center mb-6">
          <iv-league-logo.png
        </div>

        <div className="card p-6">
          <h1 className="h1 mb-4">Welcome back</h1>

          <form onSubmit={onSubmit} className="space-y-4">
            <div>
              <label className="block text-sm mb-1">Email</label>
              <input
                className="w-full px-3 py-2 rounded bg-ivy-900 border border-ivy-700 focus:outline-none focus:border-gold-500"
                type="email"
                placeholder="you@example.com"
                value={email}
                onChange={e => setEmail(e.target.value)}
                required
              />
            </div>
            <div>
              <label className="block text-sm mb-1">Password</label>
              <input
                className="w-full px-3 py-2 rounded bg-ivy-900 border border-ivy-700 focus:outline-none focus:border-gold-500"
                type="password"
                placeholder="••••••••"
                value={pwd}
                onChange={e => setPwd(e.target.value)}
                required
              />
            </div>

            <button type="submit" className="w-full py-2 rounded bg-gold-500 text-ivy-900 font-semibold hover:bg-gold-400">
              Log in
            </button>

            <div className="text-center text-sm opacity-80">Or</div>

            <button
              type="button"
              className="w-full py-2 rounded border border-ivy-700 hover:border-gold-500"
              onClick={() => alert('Wire this to GitHub OAuth (NextAuth)')}
            >
              Continue with GitHub
            </button>
          </form>

          <p className="text-sm opacity-80 mt-4 text-center">
            New here? /signupCreate an account</Link>
          </p>
        </div>
      </div>
    </main>
  )
}
LOGIN

# ----- (Optional) mock API so /api/leaderboard works if you keep it later -----
cat > src/app/api/leaderboard/route.ts << 'API'
import { NextResponse } from 'next/server'
export async function GET() {
  const rows = [
    { rank: 1, name: '@volsmith', house: 'VEGA', score: 92.4 },
    { rank: 2, name: '@delta_dan', house: 'DELTA', score: 88.7 },
    { rank: 3, name: '@thetaqueen', house: 'THETA', score: 86.1 }
  ]
  return NextResponse.json({ rows })
}
API

# ----- done; auto-install if npm is available -----
if command -v npm >/dev/null 2>&1; then
  echo "Installing dependencies (this may take a minute)..."
  npm install
  echo "Starting dev server..."
  npm run dev
else
  echo "Files created. Run 'npm install && npm run dev' to start."
