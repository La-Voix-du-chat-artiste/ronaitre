# Ronaitre

**Suivi d'abstinence privé, jour après jour.**

Réimplementation technique d'[Addict Helper](https://addict-helper.ronanbch.com/) en Ruby on Rails : application monolithe Rails 8.1, Hotwire uniquement, SQLite, déployée avec Kamal.

## Documentation

| Document | Contenu |
|---|---|
| [`docs/PRD.md`](docs/PRD.md) | Spécifications produit v1.0 — périmètre, design system (§6), matrice de permissions (§7), pages (§9), modèle de données (§12) |
| [`docs/PLAN.md`](docs/PLAN.md) | Plan d'implémentation par phases (0→6) avec tâches et critères d'acceptation |
| [`docs/DevLog.md`](docs/DevLog.md) | Journal de développement — chronologie, bugs & pièges, décisions techniques |
| [`docs/Audit-Graphique-UX-Addict-Helper.pdf`](docs/Audit-Graphique-UX-Addict-Helper.pdf) | Audit UX du produit d'origine (correctifs appliqués) |
| [`docs/Audit-Marketing-SEO-Addict-Helper.pdf`](docs/Audit-Marketing-SEO-Addict-Helper.pdf) | Audit SEO/marketing du produit d'origine (correctifs appliqués) |

## Stack

| Couche | Choix |
|---|---|
| Langage | Ruby 4.0.4 |
| Framework | Rails 8.1 (monolithe) |
| Front | Hotwire uniquement — Turbo (Drive, Streams, Frames) + Stimulus |
| Styles | Tailwind CSS v4 (`tailwindcss-rails`), tokens PRD §6 |
| Composants | ViewComponent (`app/components`) |
| Base de données | SQLite en mode WAL (`pragmas` dans `config/database.yml`) |
| Jobs / Cache / Cable | Solid Queue / Solid Cache / Solid Cable |
| Auth | Générateur natif Rails 8 (`has_secure_password`, sessions signées en cookie) |
| Tests | Minitest + Capybara (system tests headless Chrome) |
| Déploiement | Kamal 2 (Docker, Thruster) |

## Démarrage

```sh
bin/setup        # gems + base + préparation
bin/dev          # serveur (http://localhost:3000) + build tailwind --watch
```

- **Styleguide du design system** : http://localhost:3000/internal/styleguide (dev/test uniquement).
- Toutes les chaînes UI vivent dans `config/locales/fr.yml` (français uniquement, `html lang="fr"`).

## Design system (PRD §6 — ne pas modifier sans décision produit)

`app/assets/tailwind/application.css` :

- Vert profond `oklch(54% .116 174.5)` = `primary` (hero, actions in-app, jours « sans écart »)
- Orange `oklch(76% .16 72)` = `secondary` (**unique CTA public** « Commencer gratuitement »)
- Accents produit : `mint #62FFC8`, `salmon #FF9162`, `periwinkle #7A84C5`
- Typo : **system stack uniquement** (aucune webfont) ; chiffres du compteur en `.counter-digits` (mono + `tabular-nums`)

## Carte du code

```
app/
├── components/        Button, Card, Badge, Encart, SectionHeading, Logo, Field
├── controllers/
│   ├── pages/legal/aidants/csapa/feedbacks/sitemaps    # site public
│   ├── sessions/registrations/passwords                # authentification
│   ├── tracks/consumptions/milestones/share_links      # suivi
│   ├── connections/invitations/helper_dashboard        # entourage & permissions
│   ├── conversations/messages                          # messagerie temps réel
│   ├── chat                                            # compagnon IA (stub)
│   ├── notifications/settings                          # compte
│   └── shared_calendars                                # /c/:token (public, noindex)
├── jobs/milestones/sweep_job.rb     # paliers atteints (toutes les 5 min)
├── jobs/csapa/refresh_job.rb        # placeholder (Phase 6)
├── models/                          # TrackPolicy = matrice de permissions (PRD §7)
└── views/layouts/                   # public / app (sidebar sombre) / shared / application
lib/
├── sms_gateway.rb                   # abstraction SMS (StubAdapter logge)
└── chatbot.rb + chatbot/stub_provider.rb   # abstraction IA + réponses factices
```

## Abstractions « providers » (stubs par défaut — objectif technique)

- **SMS** : `lib/sms_gateway.rb` — brancher un vrai provider en affectant `SmsGateway.adapter = MonAdapter.new`. L'adaptateur stub journalise.
- **Chatbot IA** : `lib/chatbot.rb` — `Chatbot.provider = MonProvider.new` (interface : `reply(history)`). La **détection de crise** (`Chatbot.crisis?`) court-circuite toujours le provider et affiche le 3114 + ressources nationales.
- **CSAPA** : données d'exemple seedées (`db/seeds.rb`) ; `Csapa::RefreshJob` est le point de branchement pour l'annuaire public.

## SEO

- `<html lang="fr">`, titres et meta descriptions uniques par page, canonical, Open Graph complet (`og:image` 1200×630), JSON-LD (`SoftwareApplication` + `Organization` + `FAQPage`) sur l'accueil.
- `/sitemap.xml` (pages indexables uniquement), `/robots.txt` (zones privées exclues), `/llms.txt` (faits produit pour crawlers IA).
- `noindex, nofollow` : pages authentifiées (layout `app`), auth, avis, calendriers partagés (`/c/:token`), styleguide.
- Tests de non-régression : `test/controllers/seo_test.rb`.

## Tests

```sh
bin/rails test           # unitaires + requêtes (59 runs)
bin/rails test:system    # parcours navigateur (5 tests, headless Chrome)
bin/rubocop              # style
bin/brakeman             # sécurité
```

Tests de sécurité non négociables (PRD §7, PLAN Phase 3) : `test/controllers/connections_security_test.rb` — permissions par grant, détails d'écarts, révocation immédiate, isolation entre comptes.

## Déploiement (Kamal)

1. Renseigner `config/deploy.yml` : IP du VPS (`servers.web`), domaine (`proxy.host`, PRD OQ-1), registre d'images.
2. Secrets dans `.kamal/secrets` : `KAMAL_REGISTRY_PASSWORD`, `RAILS_MASTER_KEY`.
3. `bin/kamal setup` (première fois) puis `bin/kamal deploy`.

## Backups SQLite (runbook)

- **Backup** (cron quotidien déjà déclaré dans `config/recurring.yml`) :
  `bin/rails db:backup BACKUP_DIR=/rails/storage/backups BACKUP_KEEP=14`
  (copie propre via `VACUUM INTO`, sûre avec écritures concurrentes, rétention glissante).
- **Restore** : arrêter l'app, remplacer `storage/production.sqlite3`, relancer. Cache/queue/cable se recréent (`bin/rails db:prepare`) — pas besoin de les restaurer.
- Off-site : synchroniser `storage/backups` vers un stockage objet (à câbler sur le VPS cible).

## État & suite

- Phases 0→5 du plan réalisées (site public, suivi, entourage, messagerie, chatbot) + socle Phase 6 (CSAPA) — détail dans [`docs/DevLog.md`](docs/DevLog.md).
- Reste (décisions produit) : domaine OQ-1, pages guides SEO (rédaction), témoignages réels, newsletter, analytics (OQ-4), vrais providers SMS/IA.
