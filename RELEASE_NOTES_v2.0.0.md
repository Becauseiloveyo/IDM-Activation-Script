# IDM Toolbox v2.0.0

This release restarts active maintenance of the repository around a new non-activation toolbox while preserving the legacy `IAS.cmd` activation/freeze/reset implementation unchanged.

## Highlights

- Added `IDM-Toolbox.cmd` as the maintained entry point.
- Detects installed IDM path, file version, registry version, Windows version/build, architecture, and PowerShell version.
- Retrieves the latest official IDM version from the official IDM news page at runtime.
- Verifies Authenticode signatures for core IDM executables and integration DLLs.
- Adds DNS, TCP/443, HTTPS, WinHTTP proxy, user proxy, and proxy-environment diagnostics.
- Adds Chrome, Edge, and Firefox integration diagnostics.
- Generates a diagnostic report without serial/license values.
- Downloads the official IDM installer and verifies its Authenticode status and Tonec publisher before offering to launch it.
- Adds `/check`, `/diag`, `/download`, `/help`, and `/selftest` command-line modes.
- Adds Windows GitHub Actions CI.

## Project cleanup

- Removed accidental `.Rhistory`.
- Normalized Windows batch line endings through `.gitattributes`.
- Added `.gitignore`, `VERSION`, and `CHANGELOG.md`.
- Rewrote the README around the maintained toolbox architecture.

## Compatibility

Normal toolbox diagnostics do not require administrator elevation. Windows PowerShell is required.

## Legacy activation code

`IAS.cmd` remains separate legacy code. Version 2.0.0 does not modify its activation/freeze/reset internals.

## Upgrade

Replace the repository contents with v2.0.0 or pull the latest `main`, then launch:

```bat
IDM-Toolbox.cmd
```

The toolbox checks the current official IDM release at runtime, so this release note intentionally does not hard-code a specific IDM build as the long-term compatibility target.
