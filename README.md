<p align="center">
  <strong>Sonar-Swift</strong><br>
  Pluggable SwiftLint + AI Code Review CI for iOS projects.
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-ffd60a?style=flat-square" alt="MIT License"></a>
  <a href="https://github.com/Viniciuscarvalho/sonar-swift/actions"><img src="https://img.shields.io/badge/CI-GitHub_Actions-2088FF?style=flat-square&logo=github-actions&logoColor=white" alt="GitHub Actions"></a>
  <a href="https://realm.github.io/SwiftLint/"><img src="https://img.shields.io/badge/SwiftLint-strict-ff6b6b?style=flat-square" alt="SwiftLint"></a>
  <a href="https://github.com/Viniciuscarvalho/swift-code-reviewer-skill"><img src="https://img.shields.io/badge/AI_Review-Claude-a855f7?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PGNpcmNsZSBjeD0iMTIiIGN5PSIxMiIgcj0iMTAiIGZpbGw9Im5vbmUiIHN0cm9rZT0id2hpdGUiIHN0cm9rZS13aWR0aD0iMiIvPjwvc3ZnPg==&logoColor=white" alt="Claude AI Review"></a>
  <a href="#"><img src="https://img.shields.io/badge/Platform-iOS_17+-000000?style=flat-square&logo=apple&logoColor=white" alt="iOS 17+"></a>
  <a href="https://github.com/sponsors/Viniciuscarvalho"><img src="https://img.shields.io/badge/Sponsor-%E2%9D%A4-ea4aaa?style=flat-square&logo=github-sponsors&logoColor=white" alt="Sponsor"></a>
</p>

---

## What It Does

Sonar-Swift gives any iOS project **two layers of automated review** with a cost-conscious architecture:

| Layer       | Trigger                      | Cost            | What it does                                         |
| ----------- | ---------------------------- | --------------- | ---------------------------------------------------- |
| **Layer 1** | Every PR with `.swift` files | **$0**          | SwiftLint with PR comment report + 3 fix options     |
| **Layer 2** | Add `ai-review` label        | **~$0.01-0.04** | AI code review with Sonnet, token tracking in footer |

Layer 1 always runs for free. Layer 2 only runs when you explicitly ask for it.

---

## Architecture

```
PR with .swift files
    |
    +-- Layer 1: SwiftLint (always, $0)
    |     +-- Inline annotations in PR diff
    |     +-- PR comment with lint report
    |     +-- 3 fix options:
    |           1. swiftlint --fix (autofix)
    |           2. claude "fix SwiftLint issues" (local)
    |           3. Add 'ai-review' label (trigger Layer 2)
    |
    +-- Layer 2: AI Review (on-demand, label-triggered)
          +-- Triggered by 'ai-review' label only
          +-- Loads SKILL.md (lightweight, no full references)
          +-- Sonnet with max_tokens: 2048
          +-- Incremental: only reviews new commits on re-trigger
          +-- Token count + cost estimate in footer
          +-- Label auto-removed after review
```

---

## Quick Start

### 1. Install

```bash
curl -sL https://raw.githubusercontent.com/Viniciuscarvalho/sonar-swift/main/bin/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/Viniciuscarvalho/sonar-swift.git /tmp/sonar-swift
cp /tmp/sonar-swift/.swiftlint.yml .
cp -r /tmp/sonar-swift/.github .
rm -rf /tmp/sonar-swift
```

This copies three files into your project:

| File                                 | Purpose                                                   |
| ------------------------------------ | --------------------------------------------------------- |
| `.swiftlint.yml`                     | Shared lint rules (140/200 line length, 20+ opt-in rules) |
| `.github/workflows/swiftlint.yml`    | Layer 1: SwiftLint CI (free, every PR)                    |
| `.github/workflows/swift-review.yml` | Layer 2: AI Code Review (on-demand, label-triggered)      |

### 2. Configure the API Key (for Layer 2)

Layer 1 works immediately with no configuration. For Layer 2, add an Anthropic API key:

1. Create an API key at [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys)
2. Add it as a repository secret:

```bash
gh secret set ANTHROPIC_API_KEY -R your-username/your-repo
```

3. Create the trigger label:

```bash
gh label create ai-review -c 8B5CF6 -d "Trigger AI code review"
```

### 3. (Optional) Add Project-Specific Rules

Create a `.claude/CLAUDE.md` file in your repo with your project's coding standards. The AI reviewer reads it automatically and applies your custom rules on top of the default checklists.

---

## Layer 1: SwiftLint (Free)

Runs automatically on every PR that touches `.swift` files.

**What it does:**

- Runs SwiftLint with `--strict` mode
- Posts inline annotations in the PR diff
- Posts a PR comment with a formatted issue table
- Offers 3 fix options: autofix, Claude Code local, or request AI review

**Example PR comment:**

```
## SwiftLint Report

**5 issues found** (1 errors, 4 warnings)

| Severity | Location | Rule | Description |
|----------|----------|------|-------------|
| Error | `ViewModel.swift:42` | force_unwrapping | Force unwrapping should be avoided |
| Warning | `View.swift:88` | line_length | Line should be 140 characters or less |
...

### How to fix

1. **Autofix** — run locally: `swiftlint lint --fix`
2. **Claude Code** — run locally: `claude "fix the SwiftLint issues in this PR"`
3. **Request AI Review** — add the `ai-review` label to this PR
```

---

## Layer 2: AI Review (On-Demand)

Runs only when you add the `ai-review` label to a PR.

**Cost controls:**

- Uses Sonnet (best quality/cost balance)
- Loads only `SKILL.md` — no full reference cloning
- Output capped at `max_tokens: 2048`
- Diff truncated to 500 lines for large PRs
- Token count and cost estimate shown in every review footer

**Incremental reviews:**
When you add `ai-review` a second time (after pushing new commits), the workflow detects the previous review's commit SHA and only sends the new diff to the API — fewer tokens, lower cost.

| Trigger                              | Mode            | What gets reviewed                        |
| ------------------------------------ | --------------- | ----------------------------------------- |
| First `ai-review` label              | **Full**        | All `.swift` files changed vs base branch |
| Re-add `ai-review` after new commits | **Incremental** | Only files changed since last review      |

**Example footer:**

```
Layer 2 — AI Review (incremental) | Model: claude-sonnet-4-20250514 | Tokens: 1842 in / 1024 out | Cache: 0 read | Est. cost: ~$0.0209 | Stop: end_turn
```

---

## SwiftLint Rules

Sonar-Swift ships with sensible defaults for iOS 17+ / SwiftUI projects:

| Rule                  | Warning | Error |
| --------------------- | ------- | ----- |
| Line length           | 140     | 200   |
| File length           | 500     | 1000  |
| Function body length  | 50      | 100   |
| Cyclomatic complexity | 10      | 20    |
| Type body length      | 300     | 500   |

Plus: `force_unwrapping`, `implicitly_unwrapped_optional`, `modifier_order`, and [20+ opt-in rules](.swiftlint.yml).

### Customizing Rules

After installation, the `.swiftlint.yml` file lives in **your project root** — it's yours to edit. The installer will never overwrite it unless you explicitly use `--force`.

Common customizations:

```yaml
# Relax line length for your team
line_length:
  warning: 160
  error: 250

# Disable a rule you don't want
disabled_rules:
  - trailing_comma
  - force_unwrapping

# Add opt-in rules
opt_in_rules:
  - empty_count
  - closure_spacing

# Exclude generated code
excluded:
  - Pods
  - DerivedData
  - "*/Generated"

# Allow short variable names specific to your project
identifier_name:
  excluded:
    - id
    - x
    - y
    - vm
    - io # add your own
```

See the full [SwiftLint rule directory](https://realm.github.io/SwiftLint/rule-directory.html) for all available rules.

---

## Updating

To update workflows **without overwriting your custom `.swiftlint.yml`**:

```bash
curl -sL https://raw.githubusercontent.com/Viniciuscarvalho/sonar-swift/main/bin/install.sh | bash -s -- update
```

The installer supports three modes:

| Command              | `.swiftlint.yml`                    | Workflows      |
| -------------------- | ----------------------------------- | -------------- |
| `bash` (default)     | Creates if missing, skips if exists | Always updated |
| `bash -s -- update`  | Never touched                       | Always updated |
| `bash -s -- --force` | Always overwritten                  | Always updated |

---

## FAQ

**Do I need the API key for SwiftLint to work?**
No. Layer 1 (SwiftLint) runs independently with zero cost. The API key is only required for Layer 2.

**How much does the AI review cost?**
Each review costs ~$0.01-0.04 depending on diff size. The exact token count and cost estimate is shown in every review comment footer so you can monitor usage.

**How do I trigger an AI review?**
Add the `ai-review` label to any PR. The label is automatically removed after the review completes. To re-review after pushing new commits, add the label again — it will run in incremental mode.

**Is my API key safe?**
Yes. It's stored as a [GitHub encrypted secret](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions) — never exposed in logs, code, or PR comments.

**Does it work with draft PRs?**
Layer 1 (SwiftLint) runs on all PRs. Layer 2 (AI Review) skips draft PRs to save costs.

**What model does it use?**
Sonnet (`claude-sonnet-4-20250514`). The model is configured in `.github/workflows/swift-review.yml`.

---

## Requirements

- **CI (Layer 1)**: SwiftLint installed automatically by the workflow (macOS runner)
- **CI (Layer 2)**: `ANTHROPIC_API_KEY` secret + `ai-review` label created in your repo
- **Local** (optional): `brew install swiftlint`

---

## Sponsor

If Sonar-Swift saves you time, consider [sponsoring](https://github.com/sponsors/Viniciuscarvalho) to support continued development.

---

## License

[MIT](LICENSE) — Vinicius Carvalho
