# Publishing free Dozer downloads

Public source: https://github.com/disparta/Dozer

Public downloads: https://github.com/disparta/Dozer/releases

Releases are free to use and include the MPL 2.0 license, original attribution,
and instructions for obtaining the corresponding source. Publish the exact
source commit used to build each binary. This fork currently targets Apple
Silicon and macOS 13 or newer.

## One-time signing setup

1. In Xcode Settings → Accounts, select your Apple Developer Program team and
   open Manage Certificates. Create a **Developer ID Application** certificate.
   An Apple Development or Mac App Store distribution certificate cannot be
   used for this download. Creating a local Developer ID certificate requires
   the Account Holder role. You can also use Apple's
   [certificate portal instructions](https://developer.apple.com/help/account/certificates/create-developer-id-certificates/).
2. Confirm the certificate and its private key are installed on this Mac:

   ```sh
   security find-identity -v -p codesigning
   ```

3. Store notarization credentials locally in Keychain. Run this command yourself
   in Terminal and follow the private prompts for your Apple ID, team ID, and
   app-specific password:

   ```sh
   xcrun notarytool store-credentials "dozer-notary"
   ```

   Keep credentials and private keys out of the repository and chat. See
   [Apple's notarization documentation](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution).

## Build a release

1. Update `MARKETING_VERSION` and increment `CURRENT_PROJECT_VERSION` in
   `project.yml`. Update `CHANGELOG.md`. Commit the source and push to GitHub.
   The release command refuses to build from uncommitted changes.
2. Use the exact certificate name shown by `security find-identity`:

   ```sh
   SIGNING_IDENTITY='Developer ID Application: Your Name (TEAMID)' \
   NOTARY_PROFILE='dozer-notary' make release
   ```

   This builds the app, signs with hardened runtime and a secure timestamp,
   submits to Apple, staples the notarization ticket, verifies Gatekeeper
   acceptance, and packages a ZIP plus SHA-256 checksum in
   `Releases/<version>/signed/`. If any check fails, do not publish the package.
3. Unzip the final archive and move the app to Applications. Verify launch,
   hide/show, Settings, a keyboard shortcut, and launch at login. Test on the
   oldest supported macOS version before claiming that version has been tested.

## Publish on GitHub

For the first release, use tag `v4.2.1` and the matching source commit:

```sh
git tag v4.2.1
git push origin v4.2.1
gh release create v4.2.1 \
  Releases/4.2.1/signed/Dozer-4.2.1-macos-arm64.zip \
  Releases/4.2.1/signed/Dozer-4.2.1-macos-arm64.zip.sha256 \
  --repo disparta/Dozer --verify-tag --draft \
  --title 'Dozer 4.2.1 — Apple Silicon community fork' \
  --notes-file RELEASE_NOTES.md
```

Review the draft's assets and source tag, then publish it:

```sh
gh release edit v4.2.1 --repo disparta/Dozer --draft=false --latest
```

Update README's download section when the first release is available. GitHub
provides source archives for the release tag. Keep them available along with
the binary to meet the MPL source distribution requirements. Future releases
use their new version in the commands and fresh release notes.
