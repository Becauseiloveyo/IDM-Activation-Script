# Security Policy

## Supported code

Security fixes are accepted for the maintained `IDM-Toolbox.cmd` code and its GitHub Actions workflows on the current `main` branch.

The legacy `IAS.cmd` implementation is retained separately and is not part of the maintained toolbox security surface.

## Reporting a vulnerability

Please avoid publishing exploitable details, credentials, personal data, license information, or sensitive diagnostic output in a public issue.

Preferred reporting path:

1. Use GitHub's **Security** tab and private vulnerability reporting/security advisories when available.
2. Include the affected file/function, reproduction steps, expected impact, Windows version, and the smallest safe proof of concept needed to reproduce the issue.
3. Redact serial/license values, usernames, paths containing personal data, tokens, cookies, and other secrets.

## Security design expectations

Changes should preserve these properties:

- Official IDM downloads use HTTPS.
- Downloaded executables are checked with Authenticode before launch.
- The expected publisher is verified before automatic execution.
- Diagnostic reports exclude serial/license values.
- Network and browser checks should be read-only by default.
- Elevated privileges should not be requested unless a specific operation requires them.
- CI and release workflows should use the minimum GitHub token permissions required.

## Scope notes

Reports about vulnerabilities in Internet Download Manager itself should be sent to the IDM vendor rather than this repository. This project can only fix issues in its own scripts, workflows, and documentation.
