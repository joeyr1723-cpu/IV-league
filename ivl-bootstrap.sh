#!/usr/bin/env bash
set -euo pipefail

# IV League single-file bootstrap
# Usage:
#   1) Add this file to an empty GitHub repo as ivl-bootstrap.sh
#   2) Open the repo in GitHub Codespaces (or clone locally)
#   3) Run: bash ivl-bootstrap.sh

if [ -e package.json ]; then
  echo "Looks like files already exist here. Aborting to avoid overwrite." >&2
  exit 1
fi

mkdir -p src/app/api/leaderboard src/app src/components src/lib

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
    "react-dom": "18.2.0",
    "next-auth": "^4.24.7",
    "zod": "^3.23.8"
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
      fontFamily: { serif: ['EB Garamond', 'Georgia', 'serif'] }
    }
  },
  plugins: []
}
TWCFG

cat > postcss.config.js << 'POSTCSS'
module.exports = { plugins: { tailwindcss: {}, autoprefixer: {} } }
POSTCSS

cat > README.md << 'README'
# IV League (single-file bootstrap)

This repository was created from a single script. To re-run locally:

```bash
bash ivl-bootstrap.sh
npm install
npm run dev
```

Open http://localhost:3000
README

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
        <div className="max-w-5xl mx-auto p-6">
          {children}
        </div>
      </body>
    </html>
  )
}
LAYOUT

cat > src/components/HouseCrest.tsx << 'HOUSE'
export type House = 'DELTA'|'GAMMA'|'THETA'|'VEGA'|'RHO'
export function HouseCrest({ house }: { house: House }) {
  const map = {
    DELTA: { name: 'Delta', color: 'text-crimson', glyph: '∆' },
    GAMMA: { name: 'Gamma', color: 'text-royal', glyph: 'Γ' },
    THETA: { name: 'Theta', color: 'text-ivy-200', glyph: 'Θ' },
    VEGA:  { name: 'Vega', color: 'text-purple', glyph: 'ν' },
    RHO:   { name: 'Rho', color: 'text-gold-400', glyph: 'ρ' },
  } as const
  const h = map[house]
  return (
    <div className="flex items-center gap-3">
      <div className={`w-10 h-10 rounded-full border border-gold-500 grid place-items-center ${h.color} bg-ivy-800`}>
        <span className="text-xl">{h.glyph}</span>
      </div>
      <span className="uppercase tracking-widest">{h.name}</span>
    </div>
  )
}
HOUSE

cat > src/components/Leaderboard.tsx << 'LBD'
import { HouseCrest, type House } from './HouseCrest'

type Row = { rank:number; name:string; house:House; score:number }
export function Leaderboard({ rows }: { rows: Row[] }) {
  return (
    <div className="card p-4">
      <h2 className="h1 mb-4">Leader Board</h2>
      <table className="w-full text-left">
        <thead className="text-gold-400">
          <tr>
            <th className="py-2">Rank</th>
            <th>Trader</th>
            <th>House</th>
            <th className="text-right">Score</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((r) => (
            <tr key={r.rank} className="border-t border-ivy-700/60 hover:bg-ivy-800/60">
              <td className="py-2 w-16">{r.rank}</td>
              <td>{r.name}</td>
              <td className="py-2"><span className="opacity-80"><HouseCrest house={r.house} /></span></td>
              <td className="text-right font-semibold">{r.score.toFixed(1)}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
LBD

cat > src/components/Logo.tsx << 'LOGO'
export function Logo() {
  return (
    <div className="flex items-center gap-3 mb-6">
      <div className="w-12 h-12 rounded-full border border-gold-600 bg-ivy-800 grid place-items-center">
        <span className="text-gold-400 text-2xl font-semibold">IV</span>
      </div>
      <div>
        <h1 className="h1">IV League</h1>
        <p className="opacity-90 -mt-1">Compete by House. Win trophies. Master the markets.</p>
      </div>
    </div>
  )
}
LOGO

cat > src/lib/scoring.ts << 'SCORE'
export type EquityPoint = { date: string; equity: number }
export type ScoreInputs = {
  curve: EquityPoint[]
  riskFreeRateAnnual?: number
  avgLeverage?: number
  populationBenchmarks: {
    pctReturnMean: number; pctReturnStd: number;
    sharpeMean: number; sharpeStd: number;
    maxDDMean: number; maxDDStd: number;
    levMean: number; levStd: number;
  }
}
export function computeScore(i: ScoreInputs): number {
  const rfr = i.riskFreeRateAnnual ?? 0.02
  if (i.curve.length < 2) return 0
  const start = i.curve[0].equity
  const end = i.curve[i.curve.length - 1].equity
  const pctReturn = (end - start) / start
  const daily = i.curve.map((p, idx) => idx===0?0:(p.equity - i.curve[idx-1].equity)/i.curve[idx-1].equity).slice(1)
  const mean = daily.reduce((a,b)=>a+b,0)/daily.length
  const variance = daily.reduce((a,b)=>a+Math.pow(b-mean,2),0)/Math.max(1,daily.length-1)
  const stdev = Math.sqrt(variance)
  const sharpe = stdev===0?0:((mean - rfr/252)/stdev) * Math.sqrt(252)
  let peak = i.curve[0].equity, maxDD = 0
  for (const p of i.curve) { peak = Math.max(peak, p.equity); const dd = (peak - p.equity)/peak; maxDD = Math.max(maxDD, dd) }
  const lev = i.avgLeverage ?? 1
  const z = (x:number, m:number, s:number) => s>0? (x-m)/s : 0
  const pctReturnZ = z(pctReturn, i.populationBenchmarks.pctReturnMean, i.populationBenchmarks.pctReturnStd)
  const sharpeZ = z(sharpe, i.populationBenchmarks.sharpeMean, i.populationBenchmarks.sharpeStd)
  const maxDDZ = z(maxDD, i.populationBenchmarks.maxDDMean, i.populationBenchmarks.maxDDStd)
  const levZ = z(lev, i.populationBenchmarks.levMean, i.populationBenchmarks.levStd)
  const scoreRaw = 0.6*pctReturnZ + 0.25*sharpeZ - 0.1*maxDDZ - 0.05*levZ
  const score = Math.max(0, Math.min(100, 50 + 10*scoreRaw))
  return Math.round(score*10)/10
}
SCORE

cat > src/app/api/leaderboard/route.ts << 'API'
import { NextResponse } from 'next/server'
export async function GET() {
  const rows = [
    { rank: 1, name: '@volsmith', house: 'VEGA', score: 92.4 },
    { rank: 2, name: '@delta_dan', house: 'DELTA', score: 88.7 },
    { rank: 3, name: '@thetaqueen', house: 'THETA', score: 86.1 },
    { rank: 4, name: '@gamma_joe', house: 'GAMMA', score: 81.9 },
    { rank: 5, name: '@rho_ranger', house: 'RHO', score: 79.5 },
  ]
  return NextResponse.json({ rows })
}
API

cat > src/app/page.tsx << 'PAGE'
import { Leaderboard } from '@/components/Leaderboard'
import { Logo } from '@/components/Logo'

async function getRows() {
  const res = await fetch(`${process.env.NEXT_PUBLIC_BASE_URL ?? ''}/api/leaderboard`, { cache: 'no-store' })
  if (!res.ok) {
    return [
      { rank:1, name:'@volsmith', house:'VEGA', score:92.4 },
      { rank:2, name:'@delta_dan', house:'DELTA', score:88.7 },
      { rank:3, name:'@thetaqueen', house:'THETA', score:86.1 },
    ] as any
  }
  const data = await res.json()
  return data.rows
}

export default async function Home() {
  const rows = await getRows()
  return (
    <main>
      <Logo />
      <div className="grid md:grid-cols-2 gap-6">
        <section className="card p-4">
          <h3 className="h1 mb-2">Houses</h3>
          <ul className="space-y-1 opacity-90">
            <li>∆ <span className="font-semibold">Delta</span> — Conviction In Motion</li>
            <li>Γ <span className="font-semibold">Gamma</span> — Speed Favors The Prepared</li>
            <li>Θ <span className="font-semibold">Theta</span> — Time Is Our Edge</li>
            <li>ν <span className="font-semibold">Vega</span> — Order In Chaos</li>
            <li>ρ <span className="font-semibold">Rho</span> — Macro Moves Mountains</li>
          </ul>
        </section>
        <Leaderboard rows={rows} />
      </div>
      <p className="mt-6 text-sm opacity-70">Demo data only. Hook up brokers and real scoring next.</p>
    </main>
  )
}
PAGE

cat > next-env.d.ts << 'NXTENV'
/// <reference types="next" />
/// <reference types="next/image-types/global" />
// NOTE: This file should not be edited
// see https://nextjs.org/docs/basic-features/typescript for more information.
NXTENV

# Optional: if running in Codespaces, install and start
if command -v npm >/dev/null 2>&1; then
  echo "Installing dependencies (this may take a minute)..."
  npm install
  echo "Starting dev server..."
  npm run dev
else
  echo "npm not found in PATH. Files created. Run 'npm install && npm run dev' to start."
fi
