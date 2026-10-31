# bugreport

Player bug reports, filed from inside the game and published where the
developers see them, with nothing public.

**In the game.** `!bug <what happened>` files a report with the character's
place as the server knows it: zone id and name, x/y/z, rotation, character
and world. The XIVLegacy client's bug-report key (Ctrl+F12, or both gamepad
sticks held in for a second) first sends a screenshot and the end of its logs,
then opens the chat line with `!bug ` typed, so the player only writes the
note; a report from the key can be sent with no note at all.

**On the server.**

1. The client posts each file to the web server, signed in with its game
   session id: `POST /bug/attach/<file>` with `Authorization: Bearer <session id>`.
   Files: `screenshot.png` (PNG only), `game.log`, `game.prev.log`,
   `launcher.log`, `client.txt`. Logs are cut to their last
   `max_log_kb`, and the session id is taken out of them. They wait in
   `<folder>/pending/<account id>/` for `pending_minutes`.
2. `!bug` (map server) saves the report in `module_bugreport_reports` and moves
   the waiting files to `<folder>/<report id>/`. An account may file
   `per_hour` reports an hour.
3. The web server publishes every new report:
   - **GitHub**: the files are committed to `reports/<id>/` in a private
     repository and an issue is opened there with the note, the place (with a
     `!warp` line to go there), the screenshot and links to the logs.
   - **Discord**: a webhook message with the note, the place, the screenshot
     and a link to the issue (no logs). Nothing a player writes can ping
     anyone.

   A failed try is repeated with growing pauses (8 tries); the files always
   stay in the folder.

## Setting it up

1. Make a **private** GitHub repository for the reports (for example
   `you/xivlegacy-bugs`) with at least one commit (a README), and a
   [fine-grained token](https://github.com/settings/personal-access-tokens/new)
   for that repository only, with **Issues: read and write** and
   **Contents: read and write**.
2. In Discord, Channel settings → Integrations → Webhooks → New webhook, on a
   private channel; copy its URL.
3. `settings/modules.toml`: add `"bugreport"` to `enabled`.
4. `settings/bugreport.toml`:

   ```toml
   [github]
   repo = "you/xivlegacy-bugs"
   ```

   and the secrets in the environment of the web server (or as `token` /
   `webhook` in that file, which is not committed):

   ```sh
   XIVLEGACY_BUGREPORT_GITHUB_TOKEN=github_pat_...
   XIVLEGACY_BUGREPORT_DISCORD_WEBHOOK=https://discord.com/api/webhooks/...
   ```

5. Restart the map and web servers.

With neither GitHub nor Discord set up, reports are still filed and kept in
the folder. Other settings (limits, labels, the folder) are in
[`settings/default/bugreport.toml`](../../settings/default/bugreport.toml).

**Privacy.** Logs can hold a player's paths and play details: they go only to
the private repository, never to Discord. The client takes its session id and
home folder name out of them before sending, and the server takes the session
id out again.
