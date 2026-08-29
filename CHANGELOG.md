# Changelog

## 2.0.0 - 2026-08-29

Project maintenance restarted around non-activation functionality.

### Added

- `IDM-Toolbox.cmd` as the maintained entry point for diagnostics and official IDM maintenance tasks.
- Installed IDM detection from registry and standard installation paths.
- Windows/IDM status reporting.
- Runtime latest-version lookup from the official IDM news page over HTTPS.
- Installed-versus-official version comparison.
- Authenticode verification for core IDM binaries.
- DNS, TCP/443, HTTPS, WinHTTP proxy, user proxy, and proxy-environment diagnostics.
- Chrome, Edge, and Firefox installation checks.
- Native-messaging registry diagnostics for browser integration.
- Diagnostic report generation with serial/license values intentionally excluded.
- Official installer download with Authenticode and Tonec-publisher verification before launch.
- `/check`, `/diag`, `/download`, `/help`, and `/selftest` command-line modes.
- `VERSION` file and repository housekeeping rules.

### Changed

- README now describes the maintained toolbox as the primary entry point.
- Modern maintenance tasks are separated from the legacy activation implementation.
- Connectivity diagnostics use HTTPS/TCP 443 rather than relying on ICMP ping and HTTP port 80.

### Preserved

- `IAS.cmd` activation/freeze/reset internals remain unchanged in this release.
- Original IAS attribution and credits remain documented.
