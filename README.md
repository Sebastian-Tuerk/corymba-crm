# Corymba CRM

Static CRM served via GitHub Pages at
**https://sebastian-tuerk.github.io/corymba-crm/**

The whole app is a single `index.html`. New versions are produced as
`corymba_crm_vX.html` files (saved to your Downloads folder) and then
published here.

## Deploying a new version

No more manual upload-and-rename in the GitHub web UI. From this folder:

```powershell
# Publish the NEWEST corymba_crm_v*.html in your Downloads:
.\deploy.ps1

# ...or publish a specific file:
.\deploy.ps1 -Source "C:\path\to\corymba_crm_v5_7.html"

# ...skip the confirmation prompt:
.\deploy.ps1 -Force
```

The script copies the chosen file to `index.html`, commits, and pushes
to `main`. GitHub Pages redeploys automatically — live in ~1-2 minutes.
If nothing changed, it says so and does nothing.

After deploying, hard-refresh the live site with **Ctrl+F5** if you
still see the old version (browser cache).
