## Summary

Describe the change and why it is needed.

## Scope

- [ ] Maintained `IDM-Toolbox.cmd` / diagnostics / CI / documentation
- [ ] Legacy `IAS.cmd`

If this touches legacy code, keep those changes separate from unrelated toolbox maintenance where possible.

## Testing

- [ ] `IDM-Toolbox.cmd /selftest` passes when applicable
- [ ] `VERSION` matches `toolboxver` when the version changed
- [ ] Windows CMD/PowerShell behavior was checked for the affected path
- [ ] No serial/license values or other sensitive data are added to logs/reports/tests
- [ ] Download/installer changes preserve HTTPS + Authenticode/publisher verification

## Notes

List Windows/IDM versions used for manual verification, known limitations, screenshots, or follow-up work.
