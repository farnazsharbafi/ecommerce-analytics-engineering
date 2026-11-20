# Publish the corrected project

1. Download and extract the supplied ZIP.
2. In GitHub Desktop, open the local `ecommerce-analytics-engineering` repository (Repository → Show in Explorer).
3. Copy the **contents** of the ZIP into the repository's **root**. Do not add a second outer folder.
4. Keep the already-working `olist_dashboard/` folder unchanged. This ZIP intentionally does not overwrite your deployed `app.py` or existing dashboard CSVs.
5. You should see `dbt_project.yml`, `models/`, `notebooks/`, `README.md`, and `.gitignore` at repository root.
6. Commit to main and **Push origin** before opening notebooks 02–04 in Colab; they clone this GitHub repo.
7. Open a notebook using Colab File → Open notebook → GitHub, enter the repo URL and select the relevant `.ipynb`; alternatively upload the notebook with File → Open notebook → Upload.
8. Notebook 01 is safe to rerun: it checks each table and skips existing raw tables. Do not use DROP CASCADE.
9. Supply the Session pooler URI via the hidden `getpass` prompt only. Never commit `profiles.yml` or notebook outputs that contain secrets.
10. If the full pipeline already exists in Supabase, no need to rerun; GitHub visitors can review code and open the public dashboard link from README.

## Before committing

- [ ] Confirm `dbt_project.yml` is at repository root.
- [ ] Confirm models/staging/sources.yml includes `olist_order_payments`.
- [ ] Confirm `.gitignore` and no `profiles.yml` in changed files.
- [ ] Preserve the working `olist_dashboard/` folder.
- [ ] Don't commit raw customer-level Olist CSV files.
- [ ] Verify Github Desktop shows the intended files, commit, then Push origin.
