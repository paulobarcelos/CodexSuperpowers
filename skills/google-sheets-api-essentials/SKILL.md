---
name: google-sheets-api-essentials
description: Use when calling Google Sheets/Drive APIs from Node — chooses scopes, enforces truncated exponential backoff for 429/5xx, validates headers/tabs, sizes ranges conservatively, and chunks reads/writes to avoid payload and quota limits; server-only (no Edge).
---

# Google Sheets API Essentials (Node)

## Overview
Reliable patterns for Google Sheets/Drive from a Node server (Next.js API routes or Server Actions). Prioritize resilience (backoff, retries), schema validation (tabs/headers), and conservative payload sizing.

## Scopes & Auth
- Scopes: `https://www.googleapis.com/auth/drive.file`, `https://www.googleapis.com/auth/spreadsheets`
- OAuth: request offline access, handle refresh token on server
- Runtime: Node only (no Edge); avoid caching dynamic routes unless explicitly safe

## Backoff & Retry
- Failures to retry: 429 (rate limit), 5xx (`backendError`, `internalError`), `userRateLimitExceeded`, `quotaExceeded`
- Truncated exponential backoff with jitter:
  - attempt n wait ≈ `min(base * 2^(n-1) ± jitter, maxDelay)`; cap total wait window
  - start base 500–1000 ms; jitter ±20–40%
- Never infinite retry; surface actionable error after cap

## Schema & Headers
- Validate required tabs exist; create if missing (idempotent bootstrap)
- Validate header row exactly; rewrite headers if they drift (explicit repair action preferred)
- Keep a `_meta` sheet for manifest (spreadsheetId, schemaVersion, lastBootstrapAt)

## Range Sizing & Chunking
- Prefer A1 ranges with explicit header awareness (skip row 1 for data)
- Chunk writes to keep request body small (e.g., thousands of cells max per request)
- Batch read/write where possible (`spreadsheets.values.batchGet/batchUpdate`) but avoid giant multi-range payloads
- Guard against responses > ~2 MB by splitting operations

## Error Normalization
Normalize Google API error objects to a small set: `RateLimit`, `Backend`, `Auth`, `InvalidSchema`, `NotFound`, `BadRequest`. Attach `retryAfter` when provided.

## Example (TypeScript)
```ts
import { google } from 'googleapis'

export async function sheetsClient(oauth2Client:any){
  return google.sheets({version:'v4', auth: oauth2Client})
}

export async function backoff<T>(fn:()=>Promise<T>, {retries=5, baseMs=800, maxMs=5000}={}){
  let attempt=0
  for(;;){
    try{ return await fn() }catch(err:any){
      const status = err?.code || err?.response?.status
      const retriable = [429,500,502,503,504].includes(status) || /RateLimit|quotaExceeded|backendError|internalError/i.test(String(err?.message))
      if(!retriable || attempt>=retries) throw err
      const jitter = 0.3 + Math.random()*0.4 // 0.3–0.7
      const delay = Math.min(Math.floor(baseMs * Math.pow(2, attempt) * jitter), maxMs)
      await new Promise(r=>setTimeout(r, delay))
      attempt++
    }
  }
}

export async function setValues(sheets:any, spreadsheetId:string, range:string, values:any[][]){
  return backoff(()=> sheets.spreadsheets.values.update({
    spreadsheetId, range, valueInputOption:'RAW', requestBody:{ values }
  }))
}
```

## Practices
- Keep Google API calls server-side; never expose credentials to the client
- Prefer explicit repair action over silent bootstrap on load
- Log request ids/status; attach correlation ids to user-visible errors

## Pairs With
- project-local schema skill describing exact tabs/columns
- spreadsheet-repair-pattern (local or project-specific)

