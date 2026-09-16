# Ronaitre

Suivi d'abstinence privé, jour après jour. Réimplementation de [Addict Helper](https://addict-helper.ronanbch.com/) en Rails 8.1 — voir `../PRD.md` (produit) et `../PLAN.md` (plan d'implémentation).

## Stack

Ruby 4.0.4 · Rails 8.1 · SQLite (WAL) · Hotwire (Turbo + Stimulus) · Tailwind CSS v4 · ViewComponent · Solid Queue/Cache/Cable · Kamal 2

## Développement

```sh
bin/setup          # gems + db + préparation
bin/dev            # serveur + build tailwind (http://localhost:3000)
bin/rails test     # suite minitest
bin/rubocop        # style
bin/brakeman       # sécurité
```

- **Styleguide design system** : http://localhost:3000/internal/styleguide (dev/test uniquement) — tokens PRD §6, à valider contre `../docs/screenshot.png`.
- Toutes les chaînes UI vivent dans `config/locales/fr.yml`.

## Design tokens (ne pas modifier sans décision produit)

`app/assets/tailwind/application.css` : vert profond `oklch(54% .116 174.5)` (primaire/hero), orange `oklch(76% .16 72)` (CTA), police **system stack** (aucune webfont), chiffres du compteur en `font-mono` + `tabular-nums` (classe utilitaire `.counter-digits`).

## Déploiement (Kamal)

1. Renseigner `config/deploy.yml` : IP du VPS (`servers.web`), domaine (`proxy.host`), registre d'images.
2. Secrets dans `.kamal/secrets` : `KAMAL_REGISTRY_PASSWORD`, `RAILS_MASTER_KEY`.
3. `bin/kamal setup` (première fois) puis `bin/kamal deploy`.

## Backups SQLite (runbook)

- **Backup** (VPS, cron quotidien recommandé) :
  `cd /rails && bin/rails db:backup BACKUP_DIR=/backups BACKUP_KEEP=14`
  (copie propre via `VACUUM INTO`, sûre avec écritures concurrentes ; rétention glissante).
- **Restore** : arrêter l'app, remplacer `storage/production.sqlite3` par le fichier de backup, relancer. Les fichiers cache/queue/cable peuvent être recréés (`rails db:prepare`) et n'ont pas besoin d'être restaurés.
- À ajouter en cron : `0 3 * * * docker exec ronaitre-web bin/rails db:backup ...` puis sync off-site (S3/rsync) — à câbler sur le VPS cible.
