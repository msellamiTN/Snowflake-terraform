# secrets/

This directory holds local secret files that are **never committed to Git**.

The `.gitignore` excludes the entire `secrets/` directory. This README is the only tracked file here, so the directory exists in the clone without exposing any secret.

## Expected files

| File | Created when | Purpose |
|---|---|---|
| `snowflake_pat.txt` | Day 0 | Snowflake PAT for training authentication |
| `snowflake_key.p8` | Day 4 | RSA private key for JWT key-pair authentication |
| `snowflake_key.pub` | Day 4 | RSA public key (registered in Snowflake) |
| `backend.hcl` | Day 2 | Azure Blob Storage backend configuration with access keys |

## Rules

1. **Never** commit a file in this directory other than `README.md`.
2. **Never** display the content of a secret file in a screenshot, log or report.
3. **Never** pass a secret as a command-line argument — use environment variables or masked prompts.
4. **Rotate** the PAT when the training module is complete.
5. **Delete** the contents of this directory at the end of the training.

## Verify Git ignores secrets

```bash
git check-ignore secrets/snowflake_pat.txt
```

**Expected:** the command returns the path, confirming Git ignores it.

If the command returns nothing, stop and fix your `.gitignore` before proceeding.
