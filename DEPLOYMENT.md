# NextSelf AI App Store Deployment

## GitHub Actions

This repo includes two workflows:

- `iOS CI`: builds the app for iOS Simulator without code signing.
- `Archive and Upload to App Store Connect`: manually archives, exports, and uploads an IPA to App Store Connect.

## Required GitHub Secrets

Add these in GitHub under `Settings > Secrets and variables > Actions`:

- `APPLE_TEAM_ID`
- `IOS_PROVISIONING_PROFILE_NAME`
- `IOS_PROVISIONING_PROFILE_BASE64`
- `IOS_DISTRIBUTION_CERTIFICATE_BASE64`
- `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`
- `KEYCHAIN_PASSWORD`
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_PRIVATE_KEY`

The provisioning profile must match bundle ID `com.nextself.ai`.

## Upload

Run `Archive and Upload to App Store Connect` from the GitHub Actions tab and provide a new build number.

After upload, wait for Apple processing, then select the build on the App Store Connect version page.

## Submit

Before submission, App Store Connect must show no missing metadata. The current subscription products require a Review Information screenshot upload. Use:

`MarketingAssets/humanized-premium/humanized-subscription-review.png`

Do not submit until screenshots, build selection, export compliance, subscription review media, and all App Review warnings are complete.
