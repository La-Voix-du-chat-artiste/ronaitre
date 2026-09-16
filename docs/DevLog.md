# DevLog — Ronaitre

Journal de développement de la session du 16 septembre 2026.
Produit : réimplémentation d'[Addict Helper](https://addict-helper.ronanbch.com/) en Rails 8.1 / Ruby 4.0.4, conformément à [`PRD.md`](PRD.md) et [`PLAN.md`](PLAN.md).

---

## Résumé de session

- **9 commits**, de `4b833f8` (bootstrap) à `da61035` (SEO final).
- **Phases 0 → 5 livrées** + socle Phase 6 (annuaire CSAPA).
- **64 tests verts** (59 runs unit/requests + 5 system tests), RuboCop et Brakeman propres.
- Application complète : suivi d'abstinence temps réel, entourage à permissions fines, messagerie temps réel, compagnon IA avec garde-fous de crise, annuaire CSAPA, SEO complet.

## Chronologie

### Phase 0 — Fondations
- Bootstrap `rails new` (sqlite, tailwind, CI GitHub, Kamal, Solids installés d'office).
- Tokens de la PRD §6 portés en Tailwind v4 `@theme` (`oklch` exacts extraits du CSS de production de l'app d'origine) ; kit ViewComponent (Button, Card, Badge, Encart, SectionHeading, Logo, Field) + styleguide `/internal/styleguide`.
- i18n `fr` par défaut, `config.time_zone = "Paris"`.
- SQLite en WAL (`pragmas` dans `database.yml`), tâche `db:backup` (**`VACUUM INTO`** — l'API `Database#backup` a disparu du gem sqlite3 v2), rétention glissante, cron déclaré dans `recurring.yml`.

### Phase 1 — Site public & auth
- Landing en 11 sections conformes à la maquette Kimi (structure) **mais avec la peau d'origine** (vert/orange/police système) : bandeau d'aide (39 89 / 0 800 23 13 13 / 0 980 980 930), CTA unique « Commencer gratuitement », mockup produit en CSS pur avec compteur qui tick (Stimulus `live-counter`), FAQ, témoignages marqués « maquette de démonstration », footer structuré.
- Auth générateur Rails 8 : inscription, reset, rate limits (5/3 min), toggle mot de passe, micro-copy de réassurance (audit UX P7).
- Pages légales + `/avis` (remplace le bouton flottant « Faire un retour », audit P6).
- SEO de base : canonical, OG complet, JSON-LD, sitemap, robots, favicons + `og-image.png` générés via `rsvg-convert`.

### Phase 2 — Suivi core
- `presets` (5 seedés : tabac, alcool, cannabis, jeux, écrans), `tracks`, `consumptions`, `milestones`.
- **Compteur temps réel** : valeur initiale rendue serveur (`counter_time`), tick client Stimulus, `font-mono` + `tabular-nums`.
- **Écart sans reset** (décision UX signature) : noter une consommation ne touche jamais `quit_at` ; « Repartir de zéro » est une action explicite avec confirmation, qui **préserve record personnel et étapes franchies**.
- Calendrier mensuel en Turbo Frame (jours sans écart / écart / aujourd'hui / pastilles d'étapes).
- Pause/reprise (compteur figé puis repris), clôture avec conservation du record.
- Réglages : profil, anonymat, export JSON, suppression de compte en cascade.
- `Milestones::SweepJob` toutes les 5 minutes.

### Phase 3 — Entourage & permissions
- `TrackPolicy` : propriétaire / membre autorisé (grant) / extérieur.
- Invitations proche/soignant par e-mail (compte existant **ou à créer** via token — `member_id` nullable + `invited_email`).
- Réseau d'aidants (`role = aidant` à l'inscription, bio publique) + demande d'accompagnement + tableau de bord aidant `/helper`.
- Grants fins par suivi : compteur, détail des écarts, messagerie ; **révocation immédiate** (testée).
- Liens de partage `/c/:token` : par suivi **ou compte entier**, mot de passe facultatif (session de déblocage), compteur de vues, révocation ; jamais de notes personnelles côté public.
- Tests de sécurité dédiés (`connections_security_test.rb`).

### Phase 4 — Messagerie
- Conversations 1:1 par membership, Turbo Streams (Solid Cable), bulles orientées côté client (Stimulus `chat-bubble` lit `data-current-user-id` du body) pour un même broadcast côté serveur.
- Badge non-lus dans la sidebar, e-mail au destinataire, envoi **interdit sans grant `can_message`** (403).

### Phase 5 — Compagnon IA (stub technique)
- `Chatbot::Client` + `Chatbot.provider` (StubProvider à réponses déterministes).
- **Détection de crise** (`Chatbot.crisis?`, lexique FR de phrases) : court-circuite le provider, répond avec le message d'escalade (3114, 15/112, lignes nationales, CSAPA) et affiche l'encart en Turbo Stream.
- Rate limit 30/h, historique effaçable, disclaimer médical permanent.

### Phase 6 — Socle croissance
- Annuaire `/csapa` (données d'exemple seedées, recherche ville/département), `Csapa::RefreshJob` placeholder.
- Manifest PWA actif (`/manifest.webmanifest`), `theme-color` vert.

### Passe de cohérence PRD (audit complet du code)
10 écarts détectés puis corrigés (cf. § « Bugs & pièges ») : flux aidant, invitations sans compte, partage compte entier, étapes personnalisées (`DEFAULT_MILESTONES`), matrice de préférences de notification (6 événements × in-app/email/SMS, `NotificationPref.allowed?` comme point de passage unique), centre de notifications, PWA manifest, résumé dashboard.

### SEO final
- Méta : titres + descriptions uniques, canonical, OG complet + `og:image:alt`, `noindex, nofollow` (app authentifiée, auth, avis, `/c/:token`, styleguide).
- `/sitemap.xml` filtré (6 pages indexables avec priorités), `robots.txt` (zones privées + `Sitemap:`), **`/llms.txt`** (faits produit + liens + disclaimer médical pour crawlers IA).
- Tout verrouillé par `test/controllers/seo_test.rb` (7 tests).

## Bugs & pièges rencontrés (pour reprendre plus tard)

1. **`json` 3.x incompatible** avec ActiveSupport 8.1.3.1 (API positionnelle supprimée) → pin `gem "json", "~> 2.18"` (résolu en 2.21.2). Symptôme : `JSON.parse: wrong number of arguments`.
2. **Précédence Ruby `{ }`** : `render Component.new(...) { "text" }` attache le bloc à `.new`, pas à `render` → contenus vus vides dans toutes les vues. Fix systématique : `render(Component.new(...)) { ... }`. (`do...end`, lui, se lie à `render`.)
3. **Clés i18n symbolisées** : Rails 8.1 charge les YAML avec clés symboles → `item["quote"]` → nil. Fix : `item[:quote]`.
4. **Mots-clés de crise** : `%w[... en finir ...]` scindait la phrase → le mot **« en »** seul matchait tout (« envie » = crise !). Fix : tableau de phrases citées.
5. **`rate_limit` muet en test** : cache store de test = `null_store` → jamais de blocage. Fix : `memory_store` en test + `Rails.cache.clear` au setup des tests concernés.
6. **Broadcast + `Current.user`** : le partial de message ne doit pas dépendre du viewer côté modèle → orientation gérée par Stimulus.
7. **Belongs_to obligatoire par défaut** : `ShareLink#track` et `Membership#member` devaient passer `optional: true` (partage compte entier / invitation sans compte).
8. **YAML fr.yml en double clé top-level** (`auth:`, `settings:`, …) : le dernier bloc écrasait silencieusement le premier → doublons supprimés, vérification « pas de clé dupliquée » effectuée en fin de session.
9. **Nokogiri pour les tests SEO** — déjà dispo via les gems Rails ; pas d'ajout nécessaire.

## Décisions techniques notables

- **Hotwire only** : zéro React ; le compteur tique client (pas de polling, pas de cable pour le compteur), le temps réel n'est utilisé que messagerie/chat.
- **SQLite WAL** en production avec `busy_timeout` ; chemin de migration Postgres trivial (ActiveRecord standard).
- **Permissions** : un objet policy simple (`TrackPolicy`) + `grants` en base, testés comme frontière de sécurité.
- **Stubs provider** : SMS (`SmsGateway`) et IA (`Chatbot.provider`) interchangeables sans toucher aux appelants — conformément à la consigne « objectif technique ».

## État final

- `bin/rails test` → 59 runs, 0 failures ; `bin/rails test:system` → 5 tests, 0 failures.
- `bin/rubocop` → 0 offense ; `bin/brakeman` → 0 warning.
- Captures de validation dans `../tmp/` : `landing-final.png`, `dashboard.png`, `track-page.png`, `chat-crisis.png`, `csapa.png`, `settings-prefs.png`.

## Reste à faire (décisions produit, pas technique)

| Item | Bloqué par |
|---|---|
| Domaine définitif + 301 depuis addict-helper.ronanbch.com | OQ-1 |
| Pages guides SEO (rédaction : tabac, alcool, aider un proche…) | rédactionnel |
| Témoignages réels (remplacer la maquette flaguée) | terrain |
| Newsletter motivation + analytics (Plausible ?) | OQ-4 |
| Vrais adapters SMS/IA + VPS (IP) pour `kamal setup` | OQ-2, OQ-3, accès VPS |
| Annuaire CSAPA : source officielle + attribution | OQ-6 |
