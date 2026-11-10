# Anje's Recipes ♡

A little recipe book for Anje. Snap a recipe page, it gets read into a pretty digital recipe with its own blinking mascot.

- `src/page.html` – the whole app (edit this)
- `./build.sh` – rebuilds `index.html` (what GitHub Pages serves) and `site/` (for Netlify Drop)
- `photos/` – the original pages of the first three recipes

Recipes she adds are saved in her own browser, not in this repo.

## Cloud sync (free, Supabase)
1. Create a free project at supabase.com.
2. SQL Editor → paste `supabase-setup.sql` → Run.
3. Authentication → Users → Add user (email + password, auto-confirm) for each person.
4. Authentication → Sign In / Providers → turn off "Allow new users to sign up".
5. Put the Project URL and publishable (anon) key into `CLOUD` in `src/page.html`, run `./build.sh`, push.
