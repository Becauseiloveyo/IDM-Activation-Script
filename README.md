# IDM Activation Script / IDM Toolbox

[![Toolbox CI](https://github.com/Becauseiloveyo/IDM-Activation-Script/actions/workflows/toolbox-ci.yml/badge.svg)](https://github.com/Becauseiloveyo/IDM-Activation-Script/actions/workflows/toolbox-ci.yml)

This repository is maintained again as a modern **IDM diagnostics, update, integrity-check, and troubleshooting toolbox**.

The original `IAS.cmd` activation/freeze/reset implementation is preserved as separate legacy code. The current modernization work intentionally does **not** modify those internals.

## Current status

- **Maintained toolbox:** `IDM-Toolbox.cmd` v2.0.0
- **Legacy activation engine:** `IAS.cmd` v1.2
- **Supported Windows:** Windows 7/8/8.1/10/11 and corresponding Server editions where Windows PowerShell is available
- **Latest IDM compatibility:** resolved from the official IDM release page at runtime rather than hard-coded in the project
- **Release notes:** [IDM Toolbox v2.0.0](RELEASE_NOTES_v2.0.0.md)
- **Changelog:** [CHANGELOG.md](CHANGELOG.md)
- **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md)
- **Security policy:** [SECURITY.md](SECURITY.md)

Official IDM release history: <https://www.internetdownloadmanager.com/news.html>

## What was modernized

`IDM-Toolbox.cmd` provides the maintained front end for the parts of the project that do not depend on activation logic:

- Detects the installed IDM executable from the registry and standard install paths
- Reports Windows version, build, architecture, PowerShell version, IDM file version, and IDM registry version
- Retrieves the latest official IDM version over HTTPS
- Compares the installed IDM build with the current official build when version formats can be normalized
- Verifies Authenticode signatures for core IDM executables and integration DLLs
- Checks DNS, TCP/443, HTTPS, WinHTTP proxy, user proxy, and proxy environment variables
- Diagnoses Chrome, Edge, and Firefox integration prerequisites
- Searches native-messaging registry locations used by Chromium/Firefox integrations
- Generates a diagnostic report without serial/license values
- Downloads the official IDM installer and verifies both its Authenticode status and Tonec publisher before offering to launch it
- Provides non-interactive `/check`, `/diag`, `/download`, `/help`, and `/selftest` modes
- Runs a Windows CI self-test on repository changes

## Quick start

Download or clone the repository, then run:

```bat
IDM-Toolbox.cmd
```

No administrator elevation is required for normal diagnostic functions.

### Command-line modes

```text
IDM-Toolbox.cmd /check
IDM-Toolbox.cmd /diag
IDM-Toolbox.cmd /download
IDM-Toolbox.cmd /selftest
IDM-Toolbox.cmd /help
```

`/diag` writes a timestamped report to the Windows Desktop. The report intentionally excludes serial/license data.

## Main menu

```text
[1] IDM / Windows status
[2] Check latest official IDM version
[3] Verify IDM file signatures
[4] Network / proxy diagnostics
[5] Browser integration diagnostics
[6] Generate diagnostic report
[7] Download official IDM installer
[8] Open legacy IAS.cmd
[9] Official IDM / project links
[0] Exit
```

## Installer verification

The toolbox downloads the installer only from:

<https://www.internetdownloadmanager.com/transfer/download.html>

Before it offers to launch the downloaded file, it checks:

1. Windows Authenticode status is `Valid`.
2. The signing certificate subject contains `Tonec`.
3. The SHA-256 hash is displayed for inspection/logging.

If publisher/signature validation fails, the file is not launched automatically.

## Browser integration diagnostics

The browser diagnostics check:

- IDM installation path
- `IDMMsgHost.exe`
- `IDMIECC.dll`
- `IDMGetAll.dll`
- Chrome installation
- Edge installation
- Firefox installation
- Native-messaging registry entries containing IDM-related names
- Browser/integration-related values under `HKCU\Software\DownloadManager`

Official integration repair guidance:

- Chrome / Chromium: <https://www.internetdownloadmanager.com/register/new_faq/bi9.html>
- Firefox: <https://www.internetdownloadmanager.com/register/new_faq/bi4.html>

## Network diagnostics

The legacy IAS code used ping and TCP port 80 as its primary connectivity fallback. The maintained toolbox instead checks the transport path used by modern web services:

- DNS resolution
- TCP 443
- HTTPS request to the official IDM site
- WinHTTP proxy
- Windows user proxy configuration
- `HTTP_PROXY` / `HTTPS_PROXY` environment variables

This avoids treating blocked ICMP/ping as a failed Internet connection.

## Project structure

```text
IDM-Activation-Script/
├─ IAS.cmd                         Legacy IAS v1.2 activation/freeze/reset code
├─ IDM-Toolbox.cmd                 Maintained diagnostics/update/integrity toolbox
├─ README.md
├─ CONTRIBUTING.md
├─ SECURITY.md
├─ RELEASE_NOTES_v2.0.0.md
├─ CHANGELOG.md
├─ VERSION
├─ .github/
│  ├─ PULL_REQUEST_TEMPLATE.md
│  ├─ ISSUE_TEMPLATE/
│  │  ├─ bug_report.yml
│  │  ├─ feature_request.yml
│  │  └─ config.yml
│  └─ workflows/
│     ├─ toolbox-ci.yml
│     └─ release.yml
├─ .gitattributes
└─ .gitignore
```

## Releases

`.github/workflows/release.yml` automates GitHub releases and enforces version consistency before publishing.

A release tag must match the repository `VERSION` value exactly with a leading `v`. For example, `VERSION=2.0.0` requires tag `v2.0.0`. The workflow also verifies that `IDM-Toolbox.cmd` contains the same `toolboxver`.

The workflow supports both:

- pushing a matching `v*` tag; and
- manual **Run workflow** execution with a tag value.

If `RELEASE_NOTES_<tag>.md` exists, it is used as the release body. Otherwise GitHub-generated notes are used. `IDM-Toolbox.cmd` is also attached as a release asset.

## Contributing and issue reports

See [CONTRIBUTING.md](CONTRIBUTING.md) before submitting changes and [SECURITY.md](SECURITY.md) before reporting security-sensitive problems.

Structured bug/feature issue forms are included under `.github/ISSUE_TEMPLATE/`. GitHub Issues must be enabled in the repository settings for those forms to appear.

## Legacy IAS.cmd

`IAS.cmd` remains the original WindowsAddict IAS v1.2-derived implementation. Its activation-related sections have deliberately not been rewritten as part of this maintenance restart.

That separation is intentional: non-activation maintenance can continue independently without accidentally changing the legacy activation behavior.

## Troubleshooting

### IDM is not detected

Confirm that `IDMan.exe` exists in a normal installation path or that this registry value points to the executable:

```text
HKCU\Software\DownloadManager\ExePath
```

### Latest-version check fails

Run menu option **4 - Network / proxy diagnostics**. Common causes include DNS failure, HTTPS interception, VPN/proxy configuration, TLS inspection software, or blocked access to `internetdownloadmanager.com`.

### Signature verification fails

Re-download/reinstall IDM from the official download page. Do not automatically trust an installer whose Authenticode signature is invalid or whose publisher is unexpected.

## Original IAS credits

The legacy `IAS.cmd` code is derived from the original **IDM Activation Script (IAS)** project by WindowsAddict and retains its original inline attribution and credits.

Original project references:

- <https://github.com/WindowsAddict/IDM-Activation-Script>
- <https://massgrave.dev/idm-activation-script>

Additional original credits listed by IAS include Dukun Cabul, AveYo/BAU, and abbodi1406.

## Maintenance policy

The maintained code should prefer:

- HTTPS over ping/HTTP connectivity tests
- Runtime discovery over hard-coded IDM build numbers
- Authenticode verification for downloaded executables
- Read-only diagnostics before repair/reinstallation recommendations
- Explicit exclusion of serial/license values from generated reports
- Separation of maintained diagnostics from the legacy activation implementation
