#!/usr/bin/env bash
set -euo pipefail

# IV League - PRO ONE-FILE BOOTSTRAP (Splash + Login + Tailwind + Fonts)
# Usage:
#   1) Add this file to an empty GitHub repo as: ivl-pro-bootstrap.sh
#   2) Run: bash ivl-pro-bootstrap.sh && npm install && npm run dev
#   3) (Optional) Upload your crest to: public/iv-league-logo.png

if [ -e package.json ]; then
  echo "package.json already exists. Aborting to avoid overwriting." >&2
  exit 1
fi

mkdir -p src/app src/app/login src/components public

############################
# Project config files
############################
cat > package.json << 'PKG'
{
  "name": "iv-league",
  "private": true,
  "version": "0.2.0",
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

cat > postcss.config.js << 'POSTCSS'
module.exports = { plugins: { tailwindcss: {}, autoprefixer: {} } }
POSTCSS

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
      keyframes: {
        'fade-in-scale': {
          '0%':   { opacity: '0', transform: 'scale(0.96)' },
          '60%':  { opacity: '1', transform: 'scale(1.02)' },
          '100%': { opacity: '1', transform: 'scale(1)' }
        },
        'fade-in': { '0%': { opacity: '0' }, '100%': { opacity: '1' } }
      },
      animation: {
        'fade-in-scale': 'fade-in-scale 1100ms cubic-bezier(0.22, 1, 0.36, 1) forwards',
        'fade-in': 'fade-in 800ms ease-out forwards'
      }
    }
  },
  plugins: []
}
TWCFG

cat > next-env.d.ts << 'NXTENV'
/// <reference types="next" />
/// <reference types="next/image-types/global" />
// NOTE: This file should not be edited
NXTENV

cat > README.md << 'README'
# IV League (Pro Splash + Login)

- Elegant splash (crest fade/zoom), then route to `/login`
- Polished login card, Tailwind Ivy palette, professional typography
- Fallback crest at `/public/iv-crest.svg`; replace with `/public/iv-league-logo.png`

## Dev
npm install
npm run dev
# open http://localhost:3000 (or Codespaces forwarded port)
README

############################
# Styles & layout
############################
cat > src/app/globals.css << 'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Brand palette applied via Tailwind config */
:root { --bg: #0e1c10; --fg: #f3f6f3; }

html, body { height: 100%; }
body { background-color: var(--bg); color: var(--fg); }

/* Shared UI atoms */
.card { @apply bg-ivy-800/70 border border-gold-600/80 rounded-2xl shadow-xl backdrop-blur-sm; }
.h1 { @apply text-3xl md:text-4xl font-semibold tracking-wide text-gold-400; }
.input {
  @apply w-full px-3 py-2 rounded-lg bg-ivy-900/80 border border-ivy-700
         focus:outline-none focus:border-gold-500 transition;
}
.btn-primary {
  @apply w-full py-2.5 rounded-lg bg-gold-500 text-ivy-900 font-semibold
         hover:bg-gold-400 transition;
}
.btn-outline {
  @apply w-full py-2.5 rounded-lg border border-ivy-700 hover:border-gold-500 transition;
}
.link { @apply text-gold-400 hover:text-gold-500 underline; }

/* Noise + vignette background helpers */
.bg-noise {
  background-image:
    radial-gradient(ellipse at center, rgba(255,255,255,0.06) 0%, rgba(0,0,0,0) 60%);
}
CSS

cat > src/app/layout.tsx << 'LAYOUT'
import './globals.css'
import type { Metadata } from 'next'
import { EB_Garamond, Inter } from 'next/font/google'

const garamond = EB_Garamond({ subsets: ['latin'], variable: '--font-garamond' })
const inter = Inter({ subsets: ['latin'], variable: '--font-inter' })

export const metadata: Metadata = {
  title: 'IV League',
  description: 'Compete by House. Win trophies. Master the markets.',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${garamond.variable} ${inter.variable}`}>
      <body style={{ minHeight: '100vh' }}>{children}</body>
    </html>
  )
}
LAYOUT

############################
# Components
############################
cat > src/components/CrestLogo.tsx << 'CREST'
'use client'
import { useState } from 'react'

/**
 * Shows /iv-league-logo.png if present; falls back to /iv-crest.svg.
 * Uses <img> for simple onError fallback. Sized via props.
 */
export function CrestLogo({
  size = 200,
  className = '',
  alt = 'IV League crest'
}: { size?: number; className?: string; alt?: string }) {
  const [src, setSrc] = useState('/iv-league-logo.png')
  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      src={src}
      onError={() => setSrc('/iv-crest.svg')}
      width={size}
      height={size}
      alt={alt}
      className={className}
      style={{ objectFit: 'contain', display: 'block' }}
    />
  )
}
CREST

############################
# Pages
############################
cat > src/app/page.tsx << 'SPLASH'
'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { CrestLogo } from '@/components/CrestLogo'

export default function Splash() {
  const router = useRouter()

  useEffect(() => {
    const t = setTimeout(() => router.push('/login'), 1800)
    return () => clearTimeout(t)
  }, [router])

  return (
    <main className="min-h-screen relative grid place-items-center overflow-hidden">
      {/* Subtle vignette */}
      <div className="pointer-events-none absolute inset-0 bg-noise" />
      <div
        className="pointer-events-none absolute inset-0"
        style={{ backgroundImage: 'linear-gradient(180deg, rgba(255,255,255,0.04), rgba(0,0,0,0))' }}
      />

      {/* Logo with fade/scale */}
      <div className="motion-reduce:animate-none animate-fade-in-scale">
        <CrestLogo size={220} className="mx-auto drop-shadow-xl" />
      </div>

      {/* Caption */}
      <p
        className="absolute bottom-10 text-sm text-ivy-200/80 motion-reduce:hidden animate-fade-in"
        style={{ animationDelay: '900ms' }}
      >
        Entering the IV League…
      </p>
    </main>
  )
}
SPLASH

cat > src/app/login/page.tsx << 'LOGIN'
'use client'

import { useState } from 'react'
import Link from 'next/link'
import { CrestLogo } from '@/components/CrestLogo'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [pwd, setPwd] = useState('')

  const onSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // TODO: Connect to real auth (NextAuth/Clerk)
    alert(\`Logging in as \${email}\`)
  }

  return (
    <main className="min-h-screen grid place-items-center px-4">
      <div className="w-full max-w-md">
        <div className="flex flex-col items-center gap-4 mb-6">
          <CrestLogo size={96} />
          <div className="text-center">
            <h1 className="h1" style={{ fontFamily: 'var(--font-garamond), serif' }}>IV League</h1>
            <p className="opacity-80 -mt-1" style={{ fontFamily: 'var(--font-inter), sans-serif' }}>
              Compete by House. Win trophies. Master the markets.
            </p>
          </div>
        </div>

        <div className="card p-6">
          <h2 className="text-xl font-semibold text-gold-400 mb-4" style={{ fontFamily: 'var(--font-garamond), serif' }}>
            Welcome back
          </h2>

          <form onSubmit={onSubmit} className="space-y-4">
            <div>
              <label className="block text-sm mb-1">Email</label>
              <input
                className="input"
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
                className="input"
                type="password"
                placeholder="••••••••"
                value={pwd}
                onChange={e => setPwd(e.target.value)}
                required
              />
            </div>

            <button type="submit" className="btn-primary">Log in</button>

            <div className="text-center text-sm opacity-80">Or</div>

            <button
              type="button"
              className="btn-outline"
              onClick={() => alert('Wire this to GitHub OAuth (NextAuth)')}
              aria-label="Continue with GitHub"
            >
              Continue with GitHub
            </button>
          </form>

          <p className="text-sm opacity-80 mt-4 text-center">
            New here? #Create an account</Link>
          </p>
        </div>
      </div>
    </main>
  )
}
LOGIN

############################
# Fallback crest SVG (shows if PNG missing)
############################
cat > public/iv-crest.svg << 'SVG'
<svg width="600" height="600" viewBox="0 0 600 600" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="g" x1="0" x2="0" y1="0" y2="1">
      <stop offset="0%" stop-color="#25402a"/>
      <stop offset="100%" stop-color="#0e1c10"/>
    </linearGradient>
  </defs>
  <rect width="100%" height="100%" fill="transparent"/>
  <g transform="translate(60,40)">
    <path d="M240 0c75 40 150 40 240 40v220c0 130-80 230-240 300C80 490 0 390 0 260V40c90 0 165 0 240-40z" fill="url(#g)" stroke="#d4af37" stroke-width="12" />
    <!-- Ivy branch -->
    <path d="M80 340c40-60 30-110 30-200" stroke="#d4af37" stroke-width="8" fill="none"/>
    <circle cx="92" cy="180" r="20" fill="#0e1c10" stroke="#d4af37" stroke-width="6"/>
    <circle cx="100" cy="240" r="16" fill="#0e1c10" stroke="#d4af37" stroke-width="6"/>
    <circle cx="86" cy="300" r="14" fill="#0e1c10" stroke="#d4af37" stroke-width="6"/>
    <!-- IV letters -->
    <text x="180" y="260" font-family="Georgia, serif" font-size="180" fill="#d4af37" font-weight="700">IV</text>
    <!-- Ribbon -->
    <path d="M20 360c100-40 340-40 440 0l-10 50c50 20 70 30 90 44-20 14-40 29-46 34l16 62c-42-18-84-30-126-38l12-22c-50-8-140-10-180-10-40 0-80 2-130 10l12 22c-42 8-84 20-126 38l16-62c-6-5-26-20-46-34 20-14 40-24 90-44z" fill="#0e1c10" stroke="#d4af37" stroke-width="8"/>
    <text x="140" y="420" font-family="Georgia, serif" font-size="72" fill="#d4af37" font-weight="700" letter-spacing="4">LEAGUE</text>
  </g>
</svg>
SVG

echo "✅ Project scaffolded. Now run: npm install && npm run dev"
