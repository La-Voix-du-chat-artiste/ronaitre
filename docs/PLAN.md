# PLAN — Ronaitre implementation

Companion to `PRD.md` (v1.0). Phases and section references match the PRD. Each task has an ID, deliverables, and acceptance criteria (AC). Work top-to-bottom inside a phase; phases 0–2 are strictly sequential, 3–5 can partially overlap.

**Conventions for every task**

- Rails 8.1, Ruby 4.0.4, SQLite (WAL), Hotwire-only, Tailwind v4 tokens from PRD §6, all UI copy in `config/locales/fr.yml`.
- Every task ends green: `bin/rails test` (incl. system tests), `bin/rubocop`, `bin/brakeman`.
- Migrations are irreversible-safe; seeds idempotent; no comments-in-code unless required.
- Feature branch → PR → merge to `main`; `main` deploys via Kamal.

**Definition of Done per phase**: ACs checked + demo on the staging deploy + PRD traceability updated (Appendix A) + OQs for that phase resolved.

---

## Phase 0 — Fondations (≈ 3–5 d)

| ID | Task | Deliverables | Acceptance criteria |
|---|---|---|---|
| T0.1 | Toolchain | Ruby 4.0.4 (rbenv/asdf), Rails 8.1 gem, SQLite ≥ 3.45, Kamal CLI | `ruby -v` = 4.0.4, `rails -v` = 8.1 on this machine |
| T0.2 | App bootstrap | `rails new ronaitre` (sqlite default, `--css=tailwind`, propshaft, importmap, minitest, git init, MIT-free license), first commit | `bin/dev` serves the default page |
| T0.3 | Design tokens | `app/assets/tailwind/application.css` `@theme` with PRD §6.1/§6.2 tokens, radius, font stacks (sans system + mono), tabular-nums utility | Token page renders green/orange/slate exactly like `docs/screenshot.png` |
| T0.4 | Component kit | ViewComponent: `Button`, `Card`, `Badge`, `Field`, `Encart`, `SectionHeading`, `Logo`(inline SVG logomark) + preview page `/internal/styleguide` (Rails.env restricted) | Styleguide shows all variants; focus-visible rings visible |
| T0.5 | i18n & locale | `config.i18n.default_locale = :fr`, `fr.yml` skeleton, `lang="fr"` layout | All routes/pages French; no hardcoded copy |
| T0.6 | CI | GitHub Actions: lint (rubocop), security (brakeman), tests + system tests (Capybara, headless chrome) | CI green on `main` |
| T0.7 | Deploy & backups | Kamal 2 config (VPS, Thruster), SQLite WAL pragmas in `config/active_record`, nightly `sqlite3 .backup` → S3-compatible + restore runbook, Solid Queue/Cache/Cable installed and running via kamal | `kamal deploy` on staging VPS serves the styleguide over HTTPS |

**OQ to close before Phase 1**: OQ-1 (domain — needed for canonicals/OG), OQ-7 (logo variant).

---

## Phase 1 — Site public + auth (≈ 5–8 d)

| ID | Task | Deliverables | AC |
|---|---|---|---|
| T1.1 | Public layout | Header (sticky nav, mobile menu), structured footer (3 colonnes + disclaimer + « Donner un avis »), help banner (dismissible, 3 numéros + CSAPA link) | Landmarks header/nav/main/footer; matches Kimi structure with PRD §6 skin |
| T1.2 | Landing sections | All 11 sections of PRD §9.1: hero with **CSS product mockup + live ticker** (Stimulus `counter`), steps, 3 product cards, 4 engagements, entourage, 3 testimonials flagged *« Maquette de démonstration »*, FAQ accordion (Stimulus, 6 Q), final CTA | Copy imported to `fr.yml`; single CTA wording « Commencer gratuitement » everywhere (audit P2) |
| T1.3 | Auth | `bin/rails generate authentication` + signup mode (`/auth?mode=signup`), password visibility toggle, forgot/reset (Solid Queue mailer), `rate_limit`, lockout 5, session cookie Lax + rotate, remember 30 d | System tests: signup/login/logout/reset; lockout triggers; audit P7 micro-copy present |
| T1.4 | Legal pages | `/confidentialite`, `/mentions-legales`, `/cgu` with Ronaitre editor block + non-substitution clause | Linked from footer; content per PRD §14 |
| T1.5 | SEO base | Meta helper (per-route title/description), canonical, `sitemap.xml` job + `Sitemap:` in robots.txt, OG/Twitter tags + `og-image.png` 1200×630, JSON-LD partials (`SoftwareApplication`, `Organization`, `FAQPage`), favicons 180/192/512, `manifest.webmanifest`, `theme-color` | Validators pass (Rich Results, OG debugger); sitemap lists all public routes |
| T1.6 | Feedback | `/avis` form (kind, optional email, rate-limited) + mail to owner | Replaces floating button; audit P6 closed |
| T1.7 | Accessibility pass | Focus rings, aria-live for counter/toasts, contrast audit orange/green, reduced-motion | axe-core clean; manual keyboard walk of landing |

**Verification**: Lighthouse ≥ 95 (a11y, SEO, best-practices) on `/`; audit Appendix A rows P1–P9 closed.

---

## Phase 2 — Suivi core (≈ 8–12 d)

| ID | Task | Deliverables | AC |
|---|---|---|---|
| T2.1 | Models | Migrations + models: `presets`, `tracks`, `consumptions`, `milestones` (PRD §12, indexes), uniqueness/enum constraints | Schema matches PRD; factories/fixtures |
| T2.2 | Seeds | Presets catalogue (tabac, alcool, cannabis, jeux, écrans) with colours from §6.2, milestones json, unit vocabulary; idempotent | Seeded on deploy; admin-editable rows |
| T2.3 | Onboarding | Post-signup: create first track (preset or custom, quit date now/past) — « Commencez par un seul suivi… » | New user lands on dashboard with 1 track < 10 min |
| T2.4 | Dashboard | Track cards (colour, days, status), global summary, empty state | Matches dashboard tokens (incl. dark sidebar variant §6.2) |
| T2.5 | Track page | Live counter (Stimulus `live-counter`, server-truth initial, mono/tabular), months/j/h/m/s, records, milestone chips | Counter ticks 1 s; digits don't jiggle; no polling |
| T2.6 | Milestones | Definitions per preset + custom; sweep job (5 min) marks reached → celebration card + notification hook | Reaching 24 h/7 j/30 j fires exactly once (test) |
| T2.7 | Consumption logging | Quick-log modal (time, qty prefilled, note), **no reset** + copy « Un écart est une donnée… », explicit « Repartir de zéro » with confirm; history list | Slip does not change counter; explicit reset updates `quit_at` + personal-best preserved |
| T2.8 | Calendar | Monthly grid per track (Turbo Frame prev/next), clean/slip/pause/today states, milestone chips | System test: log slip → calendar shows day state |
| T2.9 | Track admin | Pause/close/restart, edit preset config, colour | Closed track read-only |
| T2.10 | Settings & data rights | Profile, anonymous display, notification prefs matrix (in-app/email/SMS flags), JSON export, account deletion cascade | Export returns all own rows; deletion hard-cascades |

**Verification**: parity checklist vs live app core (multi-tracks, presets, counter, calendar, slips); performance budget: dashboard < 300 ms server, LCP < 1.8 s.

---

## Phase 3 — Entourage & permissions (≈ 8–12 d)

| ID | Task | Deliverables | AC |
|---|---|---|---|
| T3.1 | Authorization layer | `ApplicationPolicy` (+ per-model policies), current-user grants loader, audit log of access events | Permission matrix PRD §7 enforced + unit-tested |
| T3.2 | Share links | CRUD, token (SecureRandom urlsafe), optional password (bcrypt), expiry, revoke, view counter, notification « vu » opt-in | `/c/:token` gated; revoked link 404; views counted |
| T3.3 | Public calendar | Read-only month view, no consumption notes unless granted, no personal data, its own minimal layout | No leakage of notes/identity (test) |
| T3.4 | Invitations | Email invite (proche/soignant) with signed token → signup/login → grant editor (tracks, details, messaging) | Invited member sees only granted tracks; grant change applies live |
| T3.5 | Aidants network | Public `/aidants` presentation; aidant profiles (bio, specialities, anonymous display); request/accept flow; aidant dashboard (`/helper`) with granted tracks | Follow/unfollow + revoke work; aidant sees only grants |
| T3.6 | Revocation UX | One-gesture revoke everywhere; Turbo Stream removal + re-auth check on next request | Revoked member loses access immediately (test) |

**OQ to close**: OQ-5 (soignant verification — v1 self-declared + flag for RPPS later).

---

## Phase 4 — Messagerie & notifications (≈ 6–10 d)

| ID | Task | Deliverables | AC |
|---|---|---|---|
| T4.1 | Conversations | 1:1 threads (suivi ↔ each member), Turbo Streams over Solid Cable, unread badges, last-message index | Two browsers see live messages; unread counts correct |
| T4.2 | Email notifications | Offline recipient → digest/immediate email (Action Mailer → mailcow SMTP, SPF/DKIM verified) | Email delivered; bounce handled |
| T4.3 | SMS gateway | `SmsGateway` abstraction + chosen provider (OQ-2), opt-in events (milestone, message), inbound webhook → thread, rate limits + cost cap | SMS opt-in matrix honored; cap alert fires |
| T4.4 | Email reply-in (optional) | Reply-to-post via unique reply address + inbound parsing | Reply lands in thread (if built) |
| T4.5 | Notification centre | Bell + list, read states, prefs UI wiring for all events | Events from PRD §9.9 all toggleable |

**OQ to close before T4.3**: OQ-2 (SMS provider).

---

## Phase 5 — Chatbot IA (≈ 4–6 d)

| ID | Task | Deliverables | AC |
|---|---|---|---|
| T5.1 | Provider abstraction | `Chatbot::Client` (interface: stream, safety) + chosen provider (OQ-3), token budgets/user, rate limits | Provider swappable via config only |
| T5.2 | `/chat` UI | Thread view, streaming via Turbo Streams, deletable history, system prompt FR (doux, sans jugement) | Streaming renders token-by-token; history deletable |
| T5.3 | Safety rules | Crisis-keyword detector (FR lexicon) → immediate national-numbers encart + CSAPA link, assistant turn halted; no cross-user leakage; logged for audit | Crisis test suite passes; no PII sent to provider beyond thread content |

**OQ to close before T5.1**: OQ-3 (AI provider).

---

## Phase 6 — Croissance (≈ 6–10 d)

| ID | Task | Deliverables | AC |
|---|---|---|---|
| T6.1 | CSAPA directory | `/csapa` indexable, seeded public dataset (name, address, city, phone), Stimulus city/dept filter, monthly refresh job | Sitemap includes it; source credited (OQ-6) |
| T6.2 | Guides | 4–6 SEO pages (`/guides/arreter-de-fumer`, `/guides/sevrage-alcool`, `/guides/aider-un-proche`, per-preset) linking to national dispositifs | Indexed; internal links to signup CTAs |
| T6.3 | Testimonials upgrade | Replace flagged demo quotes with real ones + moderation flow (OQ-8) | Flag removed only when real quotes in place |
| T6.4 | Motivational newsletter | Opt-in daily/weekly email (Solid Queue) | Subscribe/unsubscribe working |
| T6.5 | Analytics & Mois sans tabac | Analytics decision (OQ-4) + campaign page (November) | KPI dashboard per PRD §16 |

---

## Dependency & OQ map

| OQ | Blocks | Phase |
|---|---|---|
| OQ-1 domain | canonicals/OG/sitemap/301 plan | 0–1 |
| OQ-2 SMS provider | T4.3 | 4 |
| OQ-3 AI provider | T5.1 | 5 |
| OQ-4 analytics | T6.5 | 6 |
| OQ-5 soignant verification | T3.4/T3.5 | 3 |
| OQ-6 CSAPA data | T6.1 | 6 |
| OQ-7 logo | T0.4 | 0 |
| OQ-8 testimonials | T1.2 (flagged) → T6.3 | 1→6 |

## Standing practices

- System tests cover each security boundary (grants, shares, revocation, chatbot safety) — these are the non-negotiables.
- Parity checkpoints after Phases 3 and 5 against the live product; gaps → backlog before Phase 6.
- Runbook updated with every deploy-affecting change (backups restore, mail, SMS caps).
