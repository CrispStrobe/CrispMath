# Checkpoints, backups and transfer

Document menu → Document history saves a source checkpoint. Compare lists source,
row order, presentation and name changes. Restore first saves “Before restore”,
keeps document/row IDs, clears old computation caches and recalculates the active
worksheet. Retention is 20 checkpoints per document, 100 overall, within 1 MB.
Storage failures are shown rather than reported as success.

Settings → Workspace backups saves a portable `.json` file through the platform
file picker. The schema includes workspace settings, calculation history, user
functions, variables, graphs/links/parameters, source worksheets, 3D scene and
checkpoints. API keys, AI settings and authenticated sessions are excluded.
A SHA-256 digest detects accidental file damage; it is not an authenticity signature.
Maximum file size is 16 MB. Imported calculation caches are discarded.

Open backup validates all recognized data before presenting a restore preview.
Import worksheets preserves local settings/graphs and retains a separate source
copy for conflicting document IDs, regardless of device timestamps. Repeating
an unchanged conflict import reuses its preserved copy. Replace workspace
restores the saved workspace. Both actions save a local recovery backup first;
Previous workspace opens it for review/restore. A browser quota failure during
recovery creation aborts the restore before it changes the workspace. A later
persistence failure leaves recovery available and reports the error.

The Files route supports manual transfer through iCloud Drive or another file
provider. It does not provide automatic cloud synchronization.

## Optional Supabase cloud backup

There is no deployed Supabase project for this release. Cloud Sync is **off by
default** when no saved or build-time project settings exist. Startup leaves the
service unavailable before creating an SDK client; worksheets, checkpoints and
backup files need no account. The settings row and setup dialog make this state
explicit. Rejected configuration does not activate or persist a backend.

Cloud setup is an optional choice for someone supplying their own backend.
Previously saved valid project settings reconnect on later launches; the app
does not provision a project or silently upload a workspace. The hosted cloud
contract uses a disposable test stack, not a backend shipped with the app.

Cloud Sync accepts an HTTPS project URL and a public publishable/legacy anon key.
Existing build-time `SUPABASE_URL`/`SUPABASE_ANON_KEY` settings still take precedence.
Local setup persists independently of workspace backups. Sign in uses Supabase
Auth; Push asks before replacing the cloud snapshot. Pull opens the same restore
preview and never silently chooses the version with the latest device clock.

Setup, account and transfer feedback appears inside the Cloud Sync dialog as
an accessible live region. Starting another operation clears the previous
message. The dialog scrolls on narrow screens and keeps a Close action
available during requests. Closing it does not cancel an already submitted
server operation. Errors explain the next step without showing SDK response
bodies or credentials; signing out clears the password field and preserves
local worksheets.

Apply `supabase/migrations/20261002_user_sync_data.sql` to the selected project
only after checking its existing table and policies. It creates the expected
schema for a new project and adds the monotonic `revision` column to an existing
compatible table. Existing unrelated policies must be reviewed separately.
The owner policies use `auth.uid()` for reads and writes, following the
[Supabase RLS documentation](https://supabase.com/docs/guides/database/postgres/row-level-security).
A unique user ID prevents concurrent initial uploads from overwriting each other.
Subsequent writes match and increment the previously observed server revision,
so stale writes fail even when device timestamps are identical.

No deployed project credentials were supplied for this work. Besides SDK HTTP
fixtures and PostgreSQL policy tests, the
[hosted live contract](https://github.com/CrispStrobe/CrispMath/actions/runs/37205254939)
starts a disposable Supabase 2.119.0 stack with real Auth, PostgREST and PostgreSQL.
Five production-store checks pass: independent authenticated sessions, source
round trips and secret filtering, racing first uploads, racing revision updates,
owner/anonymous isolation, and refresh/sign-out. Fixture cleanup is also verified.

The [same workflow](../.github/workflows/sync-backend-contract.yml) additionally
builds a test app with the runner's loopback URL and public key. Its
[Playwright flow](../tool/check_cloud_sync_browser.py) uses independent desktop
and phone browser contexts for wrong-password recovery, accessible inline
feedback, GUI sign-in, Push confirmation, Pull preview,
worksheet import/recalculation, conflicting source preservation, reload and
sign-out and both dialog Close actions. Cleanup and zero uncaught browser
errors are verified. It does not inject workspace or session state. Admin access is used
only to create/delete the throwaway test account; keys and sessions are excluded
from reports. The test build is not a deployed production backend or a physical
device check. A configured user project and physical iPhone/iPad round trip
remain separate deployment checks.
