# Contributing

Thanks for contributing to IDM Toolbox.

## Project scope

The maintained part of this repository is `IDM-Toolbox.cmd`: diagnostics, update checks, integrity verification, browser-integration checks, installer verification, troubleshooting, CI, and project maintenance.

`IAS.cmd` is retained as legacy code. Keep changes to legacy activation/freeze/reset logic isolated from toolbox maintenance so reviews and regressions remain easy to reason about.

## Development guidelines

- Prefer read-only diagnostics before suggesting destructive repair steps.
- Prefer HTTPS and runtime discovery over hard-coded service/version assumptions.
- Do not include serial/license values in diagnostic reports, logs, screenshots, or test fixtures.
- Verify downloaded executables with Authenticode and expected publisher information before launching them.
- Preserve Windows CMD compatibility and CRLF line endings for `.cmd`/`.bat` files.
- Keep PowerShell commands compatible with Windows PowerShell 5.1 unless a newer requirement is documented.
- Keep normal diagnostics non-elevated where possible.

## Before opening a pull request

Run the non-destructive self-test:

```bat
IDM-Toolbox.cmd /selftest
```

If you changed the toolbox version, update all three places together:

1. `set "toolboxver=..."` in `IDM-Toolbox.cmd`
2. `VERSION`
3. `CHANGELOG.md`

For release-worthy changes, also add `RELEASE_NOTES_vX.Y.Z.md`.

## Pull requests

Keep each PR focused. Describe:

- what changed;
- why it changed;
- how it was tested;
- Windows/IDM versions used for manual verification, when applicable;
- whether the change affects only the maintained toolbox or also legacy code.

The Windows CI workflow must pass before merge for changes that touch `IDM-Toolbox.cmd`, `VERSION`, or the CI workflow itself.
