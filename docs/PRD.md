# PRD — Ronaitre

**Reimplementation of Addict Helper as a Rails 8.1 application**
Version 1.0 — 16 September 2026 — Draft for review

---

## 1. Summary

Ronaitre (working rename of [Addict Helper](https://addict-helper.ronanbch.com/)) is a French-language abstinence-tracking web app for people reducing a problematic consumption (tabac, alcool, cannabis, jeux, écrans, custom), and for the people who support them (aidants, proches, soignants).

This PRD covers a **full-parity, phased rewrite** of the existing React 19 + TanStack Start + Supabase product into **Rails 8.1 / Ruby 4.0.4, Hotwire-only, SQLite, deployed with Kamal on a VPS**. The public marketing site adopts the **structure of the Kimi proposal** (https://dknrkruahqmh2.kimi.page/) — which itself implements the corrective actions of the two September 2026 audits (`docs/Audit-Graphique-UX-Addict-Helper.pdf`, `docs/Audit-Marketing-SEO-Addict-Helper.pdf`) — while **strictly preserving the original design system** (colours + fonts) documented in §6 and visible in `docs/screenshot.png`.

**One-sentence pitch.** *Ronaitre mesure votre temps d'abstinence en temps réel, célèbre chaque étape franchie et vous entoure de vos proches, d'aidants et de soignants — dans un espace 100 % privé.*

---

## 2. Background

The original product is live and functional (per the portfolio page and audits):

- Real-time abstinence counter (months, days, hours, minutes, seconds).
- Monthly history calendar.
- Multiple parallel addictions, with customisable consumption presets.
- Read-only, password-protected calendar share link.
- Helper (aidant) invitation & authorisation with selective permissions (read-only, choice of visible addictions). Distinct technical roles: aidant, proche, soignant.
- Integrated messaging (in-site, email, SMS) between user and accepted helper.
- AI support chatbot available at any time.
- CSAPA directory pointer.
- Key UX decision to preserve: **a logged consumption ("écart") does NOT reset the abstinence counter** — the user explicitly chooses to restart, so a slip is data, not failure.

The two audits identified 11 UX issues (3 critical, 4 major) and a near-invisible SEO state (lang="en" on a French page, no sitemap, no canonical, no og:image, no JSON-LD, ~300 words of content, no FAQ, no proof). The Kimi mock applies those fixes with a new cream/coral editorial skin — **out of scope for the skin; in scope for the structure and copy patterns**.

---

## 3. Goals and non-goals

### Goals
1. **G1 — Feature parity** with the live product (see §9), delivered in phases (§15).
2. **G2 — Apply all audit corrective actions** that are frontend/SEO/UX: unified CTA, product proof in hero, help-resources encarts, FAQ, structured footer, accessibility (RGAA), SEO technical base.
3. **G3 — Preserve the original identity**: the exact colour tokens and font stack of the production app (§6). No cream/coral/Fraunces/Geist.
4. **G4 — Simplify the stack**: one Rails monolith (no SPA, no external BaaS), SQLite persistence, Hotwire interactivity, Kamal deploys.
5. **G5 — Trust by design**: privacy-first data model, French-language legal pages, medical non-substitution notice, crisis resources surfaced at the right moments.

### Non-goals (v1)
- Mobile native apps (PWA manifest + installable pages only).
- Multi-language (French only; `i18n` scaffolding ready for EN later).
- Health-data-certified hosting (HDS) — noted as a future requirement if caregiver data sharing evolves into medical record sharing (§17 Risks).
- Payments/monetisation.
- Real user testimonials at launch — the section ships flagged *« Maquette de démonstration »* until real quotes exist (audit P4).

---

## 4. Naming & brand mapping

| Legacy (Addict Helper) | Ronaitre |
|---|---|
| Product name | **Ronaitre** (everywhere: UI, emails, legal pages, meta, JSON-LD, og:site_name) |
| Tagline | *« Suivi d'abstinence privé, jour après jour. »* |
| Logomark | Recreate `/logomark-v1.png` as inline SVG (teal-green double-leaf "V"), same palette |
| Domain | ronaitre.<tld> — **open question OQ-1** (audit recommends a dedicated domain + 301s from the old subdomain) |

---

## 5. Tech stack

| Layer | Choice | Notes |
|---|---|---|
| Language | **Ruby 4.0.4** | |
| Framework | **Rails 8.1** (API-less monolith) | |
| Frontend | **Hotwire only** — Turbo (Drive, Streams, Frames) + Stimulus | No React. Real-time counter = Stimulus ticker; messaging & notifications = Turbo Streams over Action Cable |
| Styling | **Tailwind CSS v4** (`tailwindcss-rails`) | Original tokens ported to `@theme` (§6); matches the original's Tailwind v4 output |
| Components | ViewComponent | Buttons, cards, badges, form fields, encarts = a small design-system gem-able folder |
| Database | **SQLite** (WAL mode, `foreign_keys=on`) | Rails 8 default; single-writer — see §17 for concurrency notes |
| Jobs | Solid Queue | Milestone detection, email/SMS sending, digest, sitemap regen |
| Cache | Solid Cache | |
| WebSockets | Solid Cable (Action Cable) | Messaging, share-link updates |
| Auth | Rails 8 built-in authentication generator (`has_secure_password`, session + reset tokens) | No Devise. Rate-limited (`rate_limit`), lockout after N failures, magic-free classic flow |
| Email | Action Mailer → SMTP on the owner's mailcow (`mx.improv.chat`) | DKIM/SPF/DMARC configured; transactional only |
| SMS | Provider TBD (**open question OQ-2**) | Interface: `SmsGateway` abstraction so provider is swappable |
| AI chatbot | Provider TBD (**open question OQ-3**; French-capable, e.g. Mistral) | Behind `Chatbot::Client` abstraction; safety rules §9.12 |
| Asset pipeline | Propshaft + Importmap | |
| Background realtime | None needed for the counter (client-side ticker, see §9.3) | |
| Analytics | Privacy-respecting (Plausible or equivalent) — banner/consent only if required (**open question OQ-4**) | Audit §6 RGPD |
| Deploy | **Kamal 2 on a VPS** (Docker), SQLite volume + nightly backup to object storage, Thruster | |
| CI | GitHub Actions: `rubocop`, `brakeman`, `rails test`, system tests (Capybara) | |

---

## 6. Design system — **preserved from the original** (Do-not-change)

Source of truth: production stylesheet of addict-helper.ronanbch.com (Tailwind v4 theme + shadcn-style variables) and `docs/screenshot.png`. The Kimi mock's crème/corail palette (#FAF8F2 / #E5604A) and Fraunces/Geist fonts are **rejected**.

### 6.1 Core tokens

```css
:root {
  --radius: 0.625rem;

  --background:          oklch(98.5% 0.005 240);  /* near-white page bg   */
  --foreground:          oklch(22%  0.04  250);   /* dark slate text      */
  --card:                oklch(100% 0 0);
  --card-foreground:     oklch(22%  0.04  250);
  --primary:             oklch(54%  0.116 174.5); /* deep teal-green — hero bg, primary buttons, links, calendar “clean” days */
  --primary-foreground:  oklch(100% 0 0);
  --secondary:           oklch(76%  0.16  72);    /* orange — THE cta accent */
  --secondary-foreground:oklch(22%  0.04  250);
  --muted:               oklch(96.8% 0.007 247.896);
  --muted-foreground:    oklch(55.4% 0.046 257.417);
  --accent:              oklch(94%  0.03  246);
  --accent-foreground:   oklch(22%  0.04  250);
  --destructive:         oklch(57.7% 0.245 27.325);
  --destructive-foreground: oklch(98.4% 0.003 247.858);
  --border:              oklch(92.9% 0.013 255.508);
  --input:               oklch(92.9% 0.013 255.508);
  --ring:                oklch(70.4% 0.04 256.788);
}
```

### 6.2 Secondary palette (already used in the product — keep)

| Token | Value | Usage |
|---|---|---|
| Mint | `#62FFC8` | success/live states |
| Salmon | `#FF9162` | alerts/warm accent |
| Periwinkle | `#7A84C5`, light `#B8C0E4` | per-addiction track colours, calendar categories |
| Charts | `oklch(64.6% .222 41.116)`, `oklch(54% .116 174.5)`, `oklch(39.8% .07 227.392)`, `oklch(82.8% .189 84.429)` (amber-400), `oklch(76.9% .188 70.08)` | progress/insight charts |
| Dark sidebar (app) | `oklch(27.9% .041 260.031)` bg, `oklch(98.4% .003 247.858)` fg | dashboard sidebar variant |

### 6.3 Typography — **system stack, no webfont**

```
Sans: ui-sans-serif, system-ui, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"
Mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace
```

- Weights used: 400 / 500 / 600 / 700 / 800. Headings: `tracking-tight`, extrabold at hero size.
- **The abstinence counter and all durations render in `font-mono` with `tabular-nums`** (identity feature — digits must not jiggle).
- Scale (from the original): `text-xs → text-7xl`; hero title `text-7xl`/`text-4xl` mobile, `leading-none`/`leading-snug`.

### 6.4 Component rules

- Primary button: `bg-secondary` (orange) + dark text in hero contexts on green; `bg-primary` + white text for in-app primary actions. **One primary CTA wording per page: « Commencer gratuitement »** on public pages (audit P2); « Se connecter » is the only secondary.
- Radius `0.625rem` everywhere; cards `bg-card border-border`, soft shadows only.
- Hero: full-bleed `bg-primary` (deep green), white text, orange CTA — exactly as `docs/screenshot.png`.
- Focus states: visible `focus-visible` ring (`--ring`), never removed.
- Contrast: all text/CTA pairs must pass WCAG AA 4.5:1 (validate orange+dark text and white+green; audit P9).

---

## 7. Users & roles

| Role | Description | Comes from |
|---|---|---|
| **Suivi** (owner) | The tracked person; full control of their tracks and sharing | Signup |
| **Aidant** | Helper registered on the platform; can be discovered/requested by a suivi | Signup as helper |
| **Proche** | Family/friend invited by the suivi; permission-scoped view | Invitation link |
| **Soignant** | Professional caregiver (addictologue, CSAPA staff…); permission-scoped view | Invitation or profile claim (**open question OQ-5**) |
| Visitor | Anonymous public-site user | — |

A single `users` table with a `role` column (suivi/aidant) + invitation-created `memberships` carrying the proche/soignant roles. One user may hold several relationships.

### Permission matrix

| Capability | Suivi | Aidant accepted | Proche invited | Soignant invited | Share link |
|---|---|---|---|---|---|
| Create/edit own tracks, log consumptions | ✅ | — | — | — | — |
| See selected tracks' counter + milestones | own | ✅ per grant | ✅ per grant | ✅ per grant | ✅ (calendar page only) |
| See monthly calendar of a track | own | ✅ per grant | ✅ per grant | ✅ per grant | ✅ read-only |
| See consumption details (doses/notes) | own | ⚙️ per grant | ⚙️ per grant | ⚙️ per grant | ❌ |
| Message the suivi (site) | ✅ | ✅ | ✅ | ✅ | ❌ |
| Receive email/SMS notifications | own | opt-in | opt-in | opt-in | ❌ |
| Revoke access at any time | ✅ | — | — | — | ✅ (link) |
| AI chatbot | ✅ | ✅ | ❌ | ❌ | ❌ |

Every grant is explicit: per-track visibility, optional consumption-detail visibility, revocable in one gesture (product principle: *« Entouré, pas exposé »*).

---

## 8. Information architecture / routes

### Public (marketing + legal)
```
GET  /                        Landing (§10)
GET  /fonctionnement          anchor of /
GET  /tarif                   → not needed (gratuit) — covered on /
GET  /guides/*                SEO guides (Phase 6) — per-addiction pages
GET  /aidants                 Network of aidants (public presentation) 
GET  /csapa                   CSAPA directory (indexable)
GET  /confidentialite  /mentions-legales  /cgu
GET  /avis                    Feedback form (replaces floating « Faire un retour », audit P6)
GET  /auth  POST /sessions  DELETE /sessions  GET /auth?mode=signup  POST /signups
     /password (forgot/reset)
```

### App (authenticated — suivi)
```
GET  /dashboard               All tracks summary + live counter card(s)
R    /tracks                  CRUD addictions/tracks + presets
GET  /tracks/:id              Counter, milestones, calendar, history
POST /tracks/:id/consumptions   Log a consumption (slip) — no auto-reset
PATCH /tracks/:id              Restart (explicit reset of quit date), pause, close
GET  /tracks/:id/calendar/:ym Month calendar
R    /shares                  Share links (create/revoke/password)
R    /connections             Invite & manage proches/soignants; accept aidants; grants
GET  /conversations/:with     Messaging (Turbo Streams)
R    /messages
GET  /chat                    AI chatbot
GET  /settings                Profile, notifications, data export, deletion
```

### App (authenticated — aidant)
```
GET  /helper                  Aidant dashboard: followed suivis, requests, messaging
```

### Machine
```
GET  /c/:token                Public read-only calendar (password gate) 
GET  /sitemap.xml  /robots.txt  /manifest.webmanifest  /og-image.png
POST /webhooks/sms-in         Inbound SMS (if provider supports)
```

---

## 9. Functional specification

### 9.1 Public landing page (Kimi structure, original skin)

Sections in order (anchor ids from the Kimi mock):

1. **Help banner** (top, dismissible): *« Besoin d'aide maintenant ? »* — Tabac Info Service [39 89](tel:3989), Drogues Info Service [0 800 23 13 13](tel:0800231313), Alcool Info Service [0 980 980 930](tel:0980980930), link `/csapa`. (audit P3 — critical)
2. **Sticky nav**: Ronaitre logo + product name; links *Le produit · Comment ça marche · Entourage · Témoignages · FAQ*; primary CTA *« Commencer gratuitement »*; secondary *« Se connecter »*.
3. **Hero** (`bg-primary`, white text — see screenshot): badge *« Reprenez le contrôle »* (shield/sparkle icon); H1 *« Suivez votre progrès, jour après jour. »*; sub-paragraph; CTAs *« Commencer gratuitement »* (orange) + *« J'ai déjà un compte »* (outline); reassurance line *« Gratuit · Sans engagement · Vos données restent privées »* (audit P3). **Right column: pure-CSS product mockup** (audit P1) — card *« Tabac · Suivi actif »*, days in giant mono digits, live `01:12:44` ticker, milestone chips J+1 / J+7 / J+30, *« 3 mois dans 43 j »*.
4. **01 — Comment ça marche**: 3 steps (*Créez votre compte / Choisissez votre suivi / Laissez le temps compter*), micro-copy from the audit (*« Aucune question intrusive, aucune carte bancaire »*).
5. **02 — Le produit**: 3 CSS-mockup cards — *Plusieurs suivis* (Tabac 47 j / Alcool 12 j / Écrans 5 j tabs), *Des étapes qui comptent* (J+47 badge, record), *Entouré, pas exposé* (23 proches, partage révocable).
6. **03 — Pourquoi Ronaitre**: exactly 4 engagements (audit P10: reduce 6 cards to 4) — *Privé par défaut · Temps réel, vraiment · Pensé pour la rechute · Gratuit, sans piège*.
7. **04 — Entourez-vous**: 3 cards *Des aidants / Vos proches / Des soignants* + CSAPA link + medical non-substitution notice.
8. **05 — Témoignages**: 3 quotes **flagged** *« Maquette de démonstration — parcours illustratifs »* until real ones replace them.
9. **06 — FAQ**: 6 `<details>`-style accordions (Stimulus), covering: données privées ?, gratuité ?, que voient mes proches/soignant ?, et si je rechute ?, plusieurs suivis ?, remplace-t-il un professionnel ? — mirrored in `FAQPage` JSON-LD.
10. **Final CTA**: *« Le meilleur moment pour commencer, c'était hier. Le deuxième meilleur, c'est maintenant. »* + button + reassurance line.
11. **Footer (structured, audit P5)**: columns *Produit* (Comment ça marche, Fonctionnalités, Aidants & soignants, FAQ) · *Aide & ressources* (the 3 national numbers, Annuaire CSAPA) · *Légal & contact* (Confidentialité, Mentions légales, CGU, e-mail) + medical disclaimer line + *« Donner un avis »* link.

Copy lives in `config/locales/fr.yml` — all strings French, tone of the Kimi mock (doux, sans jugement), brand swapped to Ronaitre.

### 9.2 Auth

- Email + password; signup mode via `/auth?mode=signup`; Honeypot + Rails `rate_limit` on sessions/signups/passwords; lockout message after 5 failures.
- Signup micro-copy (audit P7): *« Commencez par un seul suivi, vous pourrez en ajouter d'autres ensuite »*, *« Vos données sont chiffrées et ne sont jamais partagées »*.
- Password visibility toggle (Stimulus). Reset by email (Solid Queue).
- Session: cookie, `SameSite=Lax`, rotate on login; 30-day remember.

### 9.3 Tracks & real-time counter (core)

- `Track` = one followed addiction: preset or custom name, colour (from secondary palette), `quit_at` datetime, optional consumption preset config (unit, daily dose, triggers), status (actif/pause/clos).
- Counter = `Time.current - quit_at`, rendered months/days/hours/minutes/**seconds**, **font-mono tabular-nums**, ticking every second via a Stimulus controller that sets the initial value from `data-*` (server truth) and increments locally. No polling, no cable needed for the counter (audit "temps réel, vraiment").
- Milestones (seeded per preset, custom allowed): 24 h, 7 j, 30 j, 3 mois, 6 mois, 1 an… Reached milestones computed server-side (Solid Queue sweep + on-render check), celebrated with a toast/confetti-light card and a notification to granted viewers (§9.7).
- Records: personal best per track displayed (*« Record personnel : J+112 »*).

### 9.4 Consumption logging (slips — the signature UX)

- One tap from track page: date/time (default now), quantity (optional, prefilled from preset), optional note.
- **Never resets `quit_at`.** Shows *« Votre compteur continue. Un écart est une donnée, pas un échec. »* with an explicit *« Repartir de zéro »* action the user must choose deliberately (confirm dialog).
- Calendar rendering distinguishes clean days / slip days (muted red/destructive tint) / consumption intensity.

### 9.5 Calendar

- Monthly grid per track, server-rendered (Turbo Frame, prev/next), clean/slip/pause states, today highlighted, milestone chips on their days.
- Public read-only variant at `/c/:token` behind a password (bcrypt on the share), no consumption notes unless granted, no personal data.

### 9.6 Presets catalogue (seeded)

Tabac, Alcool, Cannabis, Jeux d'argent, Écrans, + *« Créer le vôtre »*. Each preset ships: icon, colour, default milestones, unit vocabulary (cigarettes, verres, joints…), guide-page slug (Phase 6). Presets are data (YAML seed → DB), admin-editable.

### 9.7 Sharing, entourage & helpers

- **Share links** (`/shares`): per-track or whole-account, token URL, optional password, optional expiry, one-gesture revoke, view counter.
- **Invitations** (`/connections`): invite proche/soignant by email → signed token → they create an account (or log in) → the suivi defines grants: which tracks, counter+calendar only vs consumption details, messaging on/off.
- **Aidants**: a suivi can browse/ask an aidant registered on the platform (aidant profile: bio, specialities, availability, anonymised display). The suivi accepts/rejects; the same grant model applies. Aidant dashboard lists followed suivis with their granted tracks.
- All grants revocable instantly; revocation kills sessions' visibility on next request and broadcasts a Turbo Stream removal.
- Notification to the suivi when someone views a shared calendar (opt-in).

### 9.8 Messaging

- 1:1 conversations (suivi ↔ each accepted helper/proche/soignant), Turbo Streams (Solid Cable): optimistic send, live receive, unread badges, email notification on offline recipient.
- **Email channel**: same thread mirrored by email (reply-to-post inbound via Answer-Address parsing — phase 4b).
- **SMS channel**: opted-in short notifications (« Camille a franchi 30 jours 🎉 » style — without the emoji unless requested), inbound → `SmsGateway` webhook → message thread.
- No group chats v1. No attachments v1 (links only), audit-friendly minimalism.

### 9.9 Notifications & preferences

- Events: milestone reached, consumption logged (to granted viewers, opt-in), new message, invitation, grant change.
- Channels per event: in-app (bell), email, SMS — user-tunable matrix in `/settings`.
- Daily motivational email optional (audit: newsletter de motivation) — Phase 6.

### 9.10 AI chatbot

- `/chat`: supportive-conversation assistant, available 24/7 to suivi (and aidants in their dashboard context).
- **Safety rules (hard requirements):** crisis-keyword detection (suicide, overdose, detox danger) immediately surfaces the national numbers banner + CSAPA link and stops the assistant turn; no medical advice beyond generic support; no data leakage across users; conversation stored only for the user, deletable; system prompt in French, tone = the product's (*doux, sans jugement*).
- Rate-limited per user; streaming responses over Turbo Streams; provider behind `Chatbot::Client` (OQ-3).

### 9.11 CSAPA directory

- `/csapa`: indexable directory seeded from Drogues Info Service public data (name, address, phone, city, hours) with client-side filtering by city/department (Stimulus), each entry linking to maps + the national numbers. Refresh job monthly. *(Licensing/scrapping caution — OQ-6.)*

### 9.12 Feedback

- `/avis` form (type: idée/bug/témoignage, optional email) replacing the floating button, linked in footer; stores to `feedbacks`, email notification to owner. Rename per audit P6: *« Donner un avis »*.

### 9.13 Data rights

- `/settings`: JSON export of all own data; full account + data deletion (cascade, hard delete) with confirmation; retention policy stated in the privacy page (audit RGPD).

---

## 10. SEO & technical marketing (from the Marketing audit — days 1–30 scope)

| Requirement | Implementation |
|---|---|
| `<html lang="fr">` everywhere | Layout default |
| Unique `<title>` / meta description per page | Helper with per-route overrides; landing title targets *« suivi d'abstinence »*, *« arrêter de fumer application »* |
| `rel=canonical` | All public pages |
| `sitemap.xml` + `Sitemap:` in robots.txt | Solid Queue job, static routes + guides + CSAPA cities |
| Open Graph complete | `og:image` 1200×630 (branded, green/orange), `og:url`, `og:locale=fr_FR`, `og:site_name=Ronaitre`, `twitter:card=summary_large_image` |
| JSON-LD | `SoftwareApplication` + `Organization` + `FAQPage` (+ `MedicalWebPage` disclaimer context on guides) |
| Favicons/PWA | icon 180/192/512, `theme-color` = primary green, `manifest.webmanifest` |
| Performance | SSR Hotwire (no SPA hydration), budget: LCP < 1.8 s on 4G mid-tier |
| Guides (Phase 6) | `/guides/arreter-de-fumer`, `/guides/sevrage-alcool`, `/guides/aider-un-proche`, per-preset pages — each links out to the national dispositifs (angle: *l'outil privé qui complète le service public*) |
| Dedicated domain + 301 | OQ-1 |

---

## 11. Accessibility (RGAA/WCAG 2.2 AA)

- Landmarks: `header/nav/main/footer`; single H1 per page; logical heading order.
- Visible `:focus-visible` rings; full keyboard operability (menus, accordions, calendar nav).
- Contrast ≥ 4.5:1 for text, ≥ 3:1 for UI boundaries; validate orange-on-green CTA (audit P9).
- `alt` texts: logomark alt = *« Ronaitre »*; decorative mockups `aria-hidden` + text alternatives.
- Live regions (`aria-live=polite`) for counter tick (announced on focus, not every second), toasts, chat messages.
- Forms: labelled, error messages tied via `aria-describedby`, French error copy.
- Motion: `prefers-reduced-motion` disables ticker animations/celebrations.

---

## 12. Data model (SQLite / ActiveRecord)

```
users            id, email, password_digest, role (suivi|aidant), first_name, display_name,
                 anonymous?, phone (E.164, optional), notified_at, timestamps
tracks           id, user_id, preset_id?, name, color, quit_at, status (active|paused|closed),
                 preset_config json, personal_best_seconds, timestamps
presets          id, slug, name, icon, color, unit_word, milestones json, guide_slug, active
consumptions     id, track_id, occurred_at, quantity decimal?, unit?, note?, source, timestamps
milestones       id, track_id, kind, seconds, reached_at?, celebrated_at?
share_links      id, user_id, track_id?, token (unique), password_digest?, expires_at?,
                 revoked_at?, views_count, last_viewed_at
memberships      id, user_id (owner), member_id (helper user), kind (aidant|proche|soignant),
                 status (invited|active|revoked), invited_by_token?, timestamps
grants           id, membership_id, track_id, can_view_details bool, can_message bool
conversations    id, a_id, b_id, last_message_at, timestamps   (unique pair)
messages         id, conversation_id, sender_id, body, channel (site|email|sms), read_at
chat_threads     id, user_id, timestamps
chat_messages    id, chat_thread_id, role (user|assistant|system), content, tokens, created_at
csapa_facilities id, name, kind, address, zip, city, dept, phone, lat, lng, hours, source, updated_at
feedbacks        id, kind, email?, body, user_id?, created_at
notification_prefs user_id, event, in_app bool, email bool, sms bool
```

Indexes: `tracks(user_id)`, `consumptions(track_id, occurred_at)`, `share_links(token)`, `memberships(member_id,status)`, `messages(conversation_id, created_at)`. Foreign keys ON, `PRAGMA journal_mode=WAL`, `busy_timeout` set; Litestream-style continuous backup to S3-compatible storage.

---

## 13. Background jobs (Solid Queue)

- `Milestones::SweepJob` (every 5 min): compute newly reached milestones → celebrate + notify.
- `ActionMailer::MailDeliveryJob` (default) + `SmsDeliveryJob`.
- `Shares::ExpireJob`, `Csapa::RefreshJob` (monthly), `Sitemap::RegenerateJob` (daily), retention/cleanup jobs, backups.

---

## 14. Legal pages

- `/confidentialite`: data collected, purposes, retention, processors (host, mail, SMS, AI provider), rights, contact — Ronaitre as editor.
- `/mentions-legales`: editor, hosting, publication director.
- `/cgu`: service scope, **non-substitution médicale clause**, acceptable use, account deletion.
- Landing/app footer + chatbot: *« Ronaitre est un outil d'accompagnement au quotidien. Il ne se substitue pas à un avis ou à un suivi médical. »*

---

## 15. Roadmap (phased — full parity)

| Phase | Scope | Exit criteria |
|---|---|---|
| **0 — Fondations** | Rails 8.1 app (Ruby 4.0.4), SQLite WAL, Tailwind v4 with §6 tokens, ViewComponent kit, CI, Kamal deploy to VPS, seeds | "Hello Ronaitre" deployed, design-system page reviewed against screenshot |
| **1 — Site public** | Landing (§9.1), auth (§9.2), legal pages, SEO base (§10: lang, sitemap, canonical, OG, JSON-LD, favicons), `/avis` | Lighthouse ≥ 95 a11y/SEO; audits P1–P7, P9 closed on public pages |
| **2 — Suivi core** | Tracks CRUD + presets, dashboard, live counter, milestones, consumption logging (no-reset), calendar, records, settings/export | A user tracks 2 addictions, slips without reset, sees calendar |
| **3 — Entourage** | Share links (password), invitations proche/soignant, aidants network + grants, revocation, permission matrix enforced | Matrix §7 verified by system tests |
| **4 — Messagerie** | In-site realtime messaging + email notifications (+ email reply-in, + SMS if OQ-2 resolved) | Live conversation between 2 test accounts; offline → email |
| **5 — Chatbot IA** | `/chat` + safety rules + rate limits + deletable history | Crisis-keyword test suite passes; provider abstracted |
| **6 — Croissance** | CSAPA directory, guides (4–6 pages), testimonials upgrade path, motivational newsletter, Mois sans tabac page, analytics decision | Sitemap includes guides + CSAPA; first real testimonials |

Parity checkpoints after Phases 3 and 5 vs the live product; any parity gap found → backlog item before Phase 6.

---

## 16. KPIs

- **Conversion**: landing → `/auth?mode=signup` CTR; signup completion rate.
- **Activation**: % signups creating a track < 10 min; % logging a consumption in week 1.
- **Rétention**: return rate J+7 / J+30 (audit §8).
- **Entourage**: % accounts with ≥ 1 granted connection; share links created; revoke rate.
- **SEO**: impressions/positions on target queries (Search Console), organic sessions.
- **Aidants**: registered aidants, accepted requests, messages exchanged.
- **Sécurité/satisfaction**: feedback volume, chatbot crisis-handling correctness (internal audits).

---

## 17. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Sensitive health-adjacent data | Minimal data collection; no diagnosis fields; encryption at rest (disk/VPS), TLS; explicit retention & deletion; HDS question deferred but flagged (audit §6) |
| AI chatbot harmful advice | Crisis detection + hard escalation paths + logging + human-readable disclaimers; provider abstraction (OQ-3) |
| SQLite single-writer under messaging load | WAL + short transactions; Solid Cable fan-out is in-memory; measured ceiling documented; Postgres migration path kept cheap (standard AR) |
| SMS costs/spam (OQ-2) | SMS strictly opt-in, rate-limited, provider abstraction, cost cap alerts |
| Provider lock-in / pricing for chatbot | Abstraction layer + token budgets per user |
| CSAPA data licensing (OQ-6) | Source only public/open data; attribute source; takedown contact |
| SEO migration from old subdomain | 301 plan + Search Console from day 1 (OQ-1) |
| Solo-maintainer bus factor | Boring stack (Rails defaults), seeds, backups tested, runbook |

---

## 18. Open questions

- **OQ-1** Final domain for Ronaitre (dedicated domain recommended by the SEO audit; 301 strategy from addict-helper.ronanbch.com).
- **OQ-2** SMS provider (French-friendly: Brevo, Vonage, Twilio, Orange) + inbound number policy.
- **OQ-3** AI provider for the chatbot (Mistral for French/Fr-hosting narrative vs OpenAI/Anthropic) + budget caps.
- **OQ-4** Analytics choice & consent regime (Plausible cookieless avoids banner).
- **OQ-5** Soignant verification workflow (self-declared vs verified, e.g. RPPS check later).
- **OQ-6** CSAPA dataset source & refresh licensing.
- **OQ-7** Keep the original's exact logo mark (recreated SVG) or commission a light Ronaitre variant — colours unchanged.
- **OQ-8** Testimonials: ship with the flagged demo section (Phase 1) or hide until real quotes (decision affects JSON-LD/FAQ claims).

---

## Appendix A — Audit traceability

| Audit item | Where addressed |
|---|---|
| UX P1 (no product proof) | §9.1 §3 hero mockups + §02 product section |
| UX P2 (CTA inconsistency) | §6.4 single primary CTA |
| UX P3 (no reassurance/crisis resources) | §9.1 banner + reassurance lines + footer + §14 |
| UX P4 (no social proof) | §9.1 §05 flagged testimonials + §15 Phase 6 |
| UX P5 (minimal footer) | §9.1 §11 structured footer |
| UX P6 (« Faire un retour ») | §9.12 renamed + moved |
| UX P7 (bare auth) | §9.2 micro-copy + toggle |
| UX P8 (spacing) | §6.4 spacing scale, hero mockup fills space |
| UX P9 (a11y) | §11 |
| UX P10 (redundancy, no FAQ) | §9.1 §03 4 engagements + §06 FAQ |
| UX P11 (identity) | Out of skin scope; motif ideas deferred (OQ-7) |
| SEO: lang/sitemap/canonical/OG/JSON-LD/titles | §10 |
| SEO: content corpus | §15 Phase 6 |
| SEO: domain/authority | §4, OQ-1 |
| SEO: newsletter | §9.9, Phase 6 |
| RGPD/confidence | §12 §14 §17 |
