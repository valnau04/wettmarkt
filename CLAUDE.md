# NC-MARKET — Claude Code Anweisungen

## Projektübersicht
NC-Market ist eine Prediction Exchange / Wettmarkt-App für das Nikolaus-von-Kues-Gymnasium.
Nutzer wetten mit Spielgeld (₡ Coins) auf Schulereignisse (JA/NEIN-Märkte).

## Tech Stack
- **Frontend:** Vanilla HTML/CSS/JavaScript — alles in einer einzigen `index.html`
- **Backend/DB:** Supabase (PostgreSQL) mit RPC-Funktionen
- **Hosting:** Netlify (auto-deploy via GitHub)
- **Charts:** Chart.js (CDN)
- **Fonts:** IBM Plex Mono + IBM Plex Sans (Google Fonts)

## Supabase
- URL: `https://wzegepjcftnzxwdknuzq.supabase.co`
- Client wird via `const sb = supabase.createClient(...)` initialisiert
- **NIEMALS** den ANON_KEY oder die URL ändern ohne Rücksprache
- Wichtige Tabellen: `profiles`, `markets`, `markets_overview` (View), `holdings`, `trade_logs`
- Wichtige RPCs: `place_bet`, `activate_market`, `resolve_market`, `propose_market`, `set_user_role`, `try_upgrade_to_superuser`, `delete_market`

## Design-System (CSS-Variablen — NICHT ändern!)
```
--bg: #0e1014          (Haupt-Hintergrund)
--bg2: #14171c         (Karten-Hintergrund)
--bg3: #1b1f26         (Eingabefelder)
--bg4: #22262f         (Balken-Hintergrund)
--accent: #2d8fff      (Primärfarbe Blau)
--green: #4a9970       (JA / Positiv)
--red: #9e4a5a         (NEIN / Negativ)
--yellow: #a88f42      (Balance / Coins)
--text: #c2cdd8
--font-mono: 'IBM Plex Mono', monospace
--font-sans: 'IBM Plex Sans', sans-serif
--radius: 3px
```

## Datei-Struktur
```
wettmarkt/
├── index.html     ← Gesamte App (HTML + CSS + JS in einer Datei)
├── CLAUDE.md      ← Diese Datei
└── README.md
```

## Wichtige Code-Bereiche in index.html
- **Zeilen ~1-950:** CSS (Variablen, Layout, Komponenten)
- **SUPABASE CONFIG:** `const SUPABASE_URL` und `SUPABASE_ANON_KEY` — nicht anfassen
- **STATE:** `currentUser`, `currentProfile`, `currentMarketId`, etc.
- **UTILS:** `toast()`, `formatCoins()`, `escHtml()` — immer für User-Output nutzen
- **Views:** `auth-view`, `dashboard-view`, `leaderboard-view`, `market-detail-view`, `propose-view`, `portfolio-view`, `admin-view`
- **Navigation:** `showView(viewId)` Funktion — immer für View-Wechsel verwenden

## Nutzerrollen
- `user` — Standard, kein Markt-Vorschlag möglich
- `superuser` — Kann Märkte vorschlagen (wird automatisch nach 500 ₡ Investition)
- `admin` — Vollzugriff inkl. Admin-Panel

## Coding-Regeln
1. **Kein externes CSS-Framework** — nur die bestehenden CSS-Klassen und Variablen nutzen
2. **Kein zusätzlicher CDN** außer den bereits eingebundenen (Supabase, Chart.js, Google Fonts)
3. **Deutsche Kommentare** und deutsche UI-Texte (die App ist auf Deutsch)
4. **`escHtml()`** immer für User-generierte Inhalte verwenden (XSS-Schutz)
5. **`toast(msg, type)`** für Nutzer-Feedback verwenden (type: 'info', 'success', 'error')
6. **Async/await** für alle Supabase-Aufrufe
7. Neue Funktionen als `window.functionName = async function()` wenn sie aus HTML-onclick aufgerufen werden
8. Bestehende CSS-Klassen verwenden: `.card`, `.btn`, `.btn-primary`, `.badge`, `.stat-box`, `.form-group`, etc.
9. Neue SQL Functions in supabase/functions erstellen. Diese werden dann manuell in den SQL Editor in supabase kopiert.

## Was du NICHT ändern darfst
- Supabase URL und ANON_KEY
- Die CSS-Variablen (`:root { ... }`)
- Die `escHtml()` Funktion
- Die Auth-Logik (`bootUser`, `loadProfile`, `doLogin`, `doRegister`)
- Die Landing-Page-Struktur (`.lp-*` Klassen)
- Den Datenschutz-Banner (`#privacy-banner`)

## Vor jedem neuen Feature
1. Prüfen ob nötige Tabellen/Spalten vorhanden sind
2. Prüfen ob eine passende Supabase RPC existiert
3. Bestehende CSS-Klassen nutzen statt neue schreiben

## Datenbankschema

| table_name       | column_name               | data_type                | is_nullable | column_default            |
| ---------------- | ------------------------- | ------------------------ | ----------- | ------------------------- |
| holdings         | id                        | uuid                     | NO          | uuid_generate_v4()        |
| holdings         | user_id                   | uuid                     | NO          | null                      |
| holdings         | market_id                 | uuid                     | NO          | null                      |
| holdings         | yes_shares                | numeric                  | NO          | 0                         |
| holdings         | no_shares                 | numeric                  | NO          | 0                         |
| holdings         | total_invested            | numeric                  | NO          | 0                         |
| holdings         | updated_at                | timestamp with time zone | NO          | now()                     |
| leaderboard      | id                        | uuid                     | YES         | null                      |
| leaderboard      | username                  | text                     | YES         | null                      |
| leaderboard      | balance                   | numeric                  | YES         | null                      |
| leaderboard      | cohort                    | text                     | YES         | null                      |
| leaderboard      | class_level               | integer                  | YES         | null                      |
| leaderboard      | role                      | USER-DEFINED             | YES         | null                      |
| leaderboard      | created_at                | timestamp with time zone | YES         | null                      |
| leaderboard      | rank                      | bigint                   | YES         | null                      |
| markets          | id                        | uuid                     | NO          | uuid_generate_v4()        |
| markets          | title                     | text                     | NO          | null                      |
| markets          | description               | text                     | YES         | null                      |
| markets          | status                    | USER-DEFINED             | NO          | 'proposed'::market_status |
| markets          | proposed_by               | uuid                     | YES         | null                      |
| markets          | approved_by               | uuid                     | YES         | null                      |
| markets          | pool_x                    | numeric                  | YES         | null                      |
| markets          | pool_y                    | numeric                  | YES         | null                      |
| markets          | k                         | numeric                  | YES         | null                      |
| markets          | outcome                   | USER-DEFINED             | YES         | null                      |
| markets          | resolved_by               | uuid                     | YES         | null                      |
| markets          | resolved_at               | timestamp with time zone | YES         | null                      |
| markets          | proposed_at               | timestamp with time zone | NO          | now()                     |
| markets          | activated_at              | timestamp with time zone | YES         | null                      |
| markets          | created_at                | timestamp with time zone | NO          | now()                     |
| markets          | updated_at                | timestamp with time zone | NO          | now()                     |
| markets_overview | id                        | uuid                     | YES         | null                      |
| markets_overview | title                     | text                     | YES         | null                      |
| markets_overview | description               | text                     | YES         | null                      |
| markets_overview | status                    | USER-DEFINED             | YES         | null                      |
| markets_overview | proposed_by               | uuid                     | YES         | null                      |
| markets_overview | approved_by               | uuid                     | YES         | null                      |
| markets_overview | pool_x                    | numeric                  | YES         | null                      |
| markets_overview | pool_y                    | numeric                  | YES         | null                      |
| markets_overview | k                         | numeric                  | YES         | null                      |
| markets_overview | outcome                   | USER-DEFINED             | YES         | null                      |
| markets_overview | resolved_by               | uuid                     | YES         | null                      |
| markets_overview | resolved_at               | timestamp with time zone | YES         | null                      |
| markets_overview | proposed_at               | timestamp with time zone | YES         | null                      |
| markets_overview | activated_at              | timestamp with time zone | YES         | null                      |
| markets_overview | created_at                | timestamp with time zone | YES         | null                      |
| markets_overview | updated_at                | timestamp with time zone | YES         | null                      |
| markets_overview | prob_yes                  | numeric                  | YES         | null                      |
| markets_overview | trade_count               | bigint                   | YES         | null                      |
| markets_overview | proposer_name             | text                     | YES         | null                      |
| payout_logs      | id                        | uuid                     | NO          | uuid_generate_v4()        |
| payout_logs      | market_id                 | uuid                     | NO          | null                      |
| payout_logs      | user_id                   | uuid                     | NO          | null                      |
| payout_logs      | winning_shares            | numeric                  | NO          | null                      |
| payout_logs      | payout_amount             | numeric                  | NO          | null                      |
| payout_logs      | paid_at                   | timestamp with time zone | NO          | now()                     |
| profiles         | id                        | uuid                     | NO          | null                      |
| profiles         | username                  | text                     | NO          | null                      |
| profiles         | role                      | USER-DEFINED             | NO          | 'user'::user_role         |
| profiles         | balance                   | numeric                  | NO          | 1000.0                    |
| profiles         | cohort                    | text                     | YES         | null                      |
| profiles         | class_level               | integer                  | YES         | null                      |
| profiles         | age                       | integer                  | YES         | null                      |
| profiles         | gender                    | text                     | YES         | null                      |
| profiles         | risk_affinity_self_report | integer                  | YES         | null                      |
| profiles         | notes                     | text                     | YES         | null                      |
| profiles         | created_at                | timestamp with time zone | NO          | now()                     |
| profiles         | updated_at                | timestamp with time zone | NO          | now()                     |
| trade_logs       | id                        | uuid                     | NO          | uuid_generate_v4()        |
| trade_logs       | timestamp                 | timestamp with time zone | NO          | now()                     |
| trade_logs       | user_id                   | uuid                     | NO          | null                      |
| trade_logs       | market_id                 | uuid                     | NO          | null                      |
| trade_logs       | direction                 | USER-DEFINED             | NO          | null                      |
| trade_logs       | investment_amount         | numeric                  | NO          | null                      |
| trade_logs       | shares_received           | numeric                  | NO          | null                      |
| trade_logs       | pool_x_before             | numeric                  | NO          | null                      |
| trade_logs       | pool_y_before             | numeric                  | NO          | null                      |
| trade_logs       | pool_x_after              | numeric                  | NO          | null                      |
| trade_logs       | pool_y_after              | numeric                  | NO          | null                      |
| trade_logs       | price_before_trade        | numeric                  | NO          | null                      |
| trade_logs       | price_after_trade         | numeric                  | NO          | null                      |
| trade_logs       | price_impact              | numeric                  | YES         | null                      |
| trade_logs       | session_id                | text                     | YES         | null                      |
| trade_logs       | device_type               | text                     | YES         | null                      |
| trade_logs       | created_at                | timestamp with time zone | NO          | now()                     |

## Bekannte Eigenheiten
- Die App ist eine Single-Page-App ohne Router — Views werden per CSS (`display:none/block`) gewechselt
- `showView(viewId)` triggert automatisch Daten-Laden (loadMarkets, loadLeaderboard, etc.)
- Mobile Bottom Nav ist nur auf kleinen Screens sichtbar (CSS @media max-width: 640px)
- Der Leaderboard-Score ist: `(balance + noch_investiertes_Kapital) - 1000 ₡ Startkapital`
- AMM-Algorithmus: Constant Product Market Maker (CPMM) — Pool X × Y = K
