# CalmPal Release — Brief 08 & 08b Result Note

## Google Play API Upload Summary
- **App / Package Name**: `com.calmpal.app`
- **Track**: `Closed test`
- **Release Status**: `draft` (NOT rolled out to production or active testers)
- **Version Name**: `5.6.0`
- **Version Code**: `2`
- **AAB File**: `deliverables/calmpal-release.aab` (128,507,722 bytes, 122.6 MB with Play Asset Delivery `:sound_assets` install-time pack)
- **AAB SHA-1**: `2b8ee703ba8f88ae16cf59c42baeceb14a0c2967`
- **AAB SHA-256**: `1d10d05e24ca0d2fbdb004e0acb9a5756c753769955a1a50eddce6e926a7a491`

---

## Brief 08 Attempt (Initial Report)
- Scope check via standard `gcloud auth print-access-token` returned 403 `ACCESS_TOKEN_SCOPE_INSUFFICIENT` due to missing `https://www.googleapis.com/auth/androidpublisher` scope on the default CLI login.
- As required by Brief 08, work stopped without attempting unsupported service account or key file workarounds.

---

## Brief 08b Execution (Retry Outcome)
1. **OAuth Consent & Scopes**:
   - `gcloud auth application-default login` completed with scopes:
     `https://www.googleapis.com/auth/androidpublisher,https://www.googleapis.com/auth/cloud-platform`
   - Verified via `https://oauth2.googleapis.com/tokeninfo`: `androidpublisher` scope confirmed present.
   - Quota project configured: `play-upload-511210`.

2. **Play Developer API Edit & Upload Flow**:
   - **Edit Created**: `POST https://androidpublisher.googleapis.com/androidpublisher/v3/applications/com.calmpal.app/edits`
     - Edit ID: `05989813988021451201`
   - **Bundle Upload**: Resumable upload chunked to `https://androidpublisher.googleapis.com/upload/androidpublisher/v3/applications/com.calmpal.app/edits/05989813988021451201/bundles?uploadType=resumable`
     - Response: `{"versionCode": 2, "sha1": "2b8ee703ba8f88ae16cf59c42baeceb14a0c2967", "sha256": "1d10d05e24ca0d2fbdb004e0acb9a5756c753769955a1a50eddce6e926a7a491"}`
   - **Track Assignment**: Assigned to track `Closed test` with status `draft`:
     - Endpoint: `PUT .../edits/05989813988021451201/tracks/Closed%20test`
     - Payload: `{"track": "Closed test", "releases": [{"versionCodes": ["2"], "status": "draft"}]}`
   - **Edit Commit**:
     - `POST .../edits/05989813988021451201:commit`
     - Result: `{'id': '05989813988021451201', 'expiryTimeSeconds': '1791695071'}`

3. **Post-Commit Verification**:
   - Queried track `Closed test` on fresh read edit:
     ```json
     {
       "track": "Closed test",
       "releases": [
         {
           "name": "5.6.0",
           "versionCodes": [
             "2"
           ],
           "status": "draft"
         }
       ]
     }
     ```
   - Confirmed: Bundle with versionCode 2 is successfully committed on `Closed test` as **draft**.

---

## Acceptance Criteria Verification
- [x] Token has the `androidpublisher` scope (proven by tokeninfo output)
- [x] Bundle uploaded without 403; `Closed test` track shows a DRAFT release with versionCode 2
- [x] Result note written and uploaded to Google Drive `deliverables/`
- [x] Zero changes to Play Console web UI
