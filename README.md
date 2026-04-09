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

Sonar-Swift gives any iOS project **two layers of automated review** on every PR:

1. **SwiftLint** — fast static analysis with `--strict` mode and inline annotations
2. **AI Code Review** — powered by [Claude](https://anthropic.com) + the [swift-code-reviewer-skill](https://github.com/Viniciuscarvalho/swift-code-reviewer-skill), covering concurrency, security, performance, architecture, and SwiftUI best practices

Install once, get both.

---

## Architecture

```
PR with .swift files
    │
    ├── Job 1: SwiftLint (free, fast)
    │     └── Inline annotations in PR diff
    │
    └── Job 2: AI Code Review (requires API key)
          ├── Loads swift-code-reviewer-skill checklists
          │     ├── Swift 6+ quality (actors, Sendable, async/await)
          │     ├── SwiftUI patterns (state, property wrappers, modern APIs)
          │     ├── Performance (view updates, ForEach, layout)
          │     ├── Security (force unwraps, keychain, input validation)
          │     └── Architecture (MVVM, DI, separation of concerns)
          ├── Reads .claude/CLAUDE.md for project-specific rules (if present)
          └── Posts structured review with severity levels + inline comments
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

| File                                 | Purpose                                                                     |
| ------------------------------------ | --------------------------------------------------------------------------- |
| `.swiftlint.yml`                     | Shared lint rules (140/200 line length, force_unwrapping, 20+ opt-in rules) |
| `.github/workflows/swiftlint.yml`    | SwiftLint CI — runs on every PR with `--strict`                             |
| `.github/workflows/swift-review.yml` | AI Code Review CI — Claude-powered review with inline comments              |

### 2. Configure the API Key

The AI review workflow requires an **Anthropic API key**. Without it, Job 1 (SwiftLint) still works normally — Job 2 (AI Review) simply won't run.

**Step by step:**

1. Create an API key at [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys)
2. Add it as a repository secret:

```bash
gh secret set ANTHROPIC_API_KEY -R your-username/your-repo
```

This opens a secure prompt — paste your key there. It is **never** stored in code or logs.

> **Cost:** The default model is `sonnet` (Claude Sonnet), which provides the best balance between review quality and cost. You can change the model in `.github/workflows/swift-review.yml` — see [Changing the AI Model](#changing-the-ai-model) below.

### 3. (Optional) Add Project-Specific Rules

Create a `.claude/CLAUDE.md` file in your repo with your project's coding standards. The AI reviewer reads it automatically and applies your custom rules on top of the default checklists.

---

## How the AI Review Works

The review runs in two modes to avoid redundant work:

| Event                        | Mode            | What gets reviewed                             |
| ---------------------------- | --------------- | ---------------------------------------------- |
| PR opened / ready for review | **Full**        | All `.swift` files changed vs base branch      |
| New commits pushed           | **Incremental** | Only `.swift` files changed in the new commits |

This means if you push a fix to one file, only that file gets re-reviewed — not the entire PR.

### Flow

1. The workflow detects which Swift files changed (full or incremental depending on the event)
2. It clones the [swift-code-reviewer-skill](https://github.com/Viniciuscarvalho/swift-code-reviewer-skill) reference checklists (8 documents covering Swift quality, SwiftUI, performance, security, architecture, and more)
3. [claude-code-action](https://github.com/anthropics/claude-code-action) reads each changed file and applies the checklists
4. It posts a structured PR comment:

```
### Swift Code Review (incremental)

**Files reviewed**: 1 | **Issues**: 0

#### Summary
Fix correctly addresses the @MainActor isolation issue from the previous review.

#### Good Practices
- Proper actor isolation applied to LoginViewModel
```

On full reviews, the report includes all severity levels, inline comments on Critical/High issues, and a prioritized action items checklist.

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
No. SwiftLint runs independently. The API key is only required for the AI review job.

**How much does the AI review cost?**
With Sonnet (default), typical PR reviews cost a few cents. You can monitor usage at [console.anthropic.com](https://console.anthropic.com).

**Can I use a different Claude model?**
Yes — see [Changing the AI Model](#changing-the-ai-model) below.

**Is my API key safe?**
Yes. It's stored as a [GitHub encrypted secret](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions) — never exposed in logs, code, or PR comments.

**Does it work with draft PRs?**
No. The AI review skips draft PRs to save costs. It runs when the PR is marked as ready.

---

## Changing the AI Model

The default model is **Sonnet** (`sonnet`), which provides high-quality reviews at a reasonable cost. To change it, edit the `model:` field in `.github/workflows/swift-review.yml`:

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    model: sonnet # <-- change this
```

Available models:

| Model         | ID                          | Best for                                | Relative cost |
| ------------- | --------------------------- | --------------------------------------- | ------------- |
| **Haiku 4.5** | `claude-haiku-4-5-20251001` | Lowest cost, fast reviews               | $             |
| **Sonnet**    | `sonnet`                    | Best quality/cost balance (default)     | $$            |
| **Opus**      | `opus`                      | Deepest analysis, complex architectures | $$$           |

---

## Requirements

- **CI (SwiftLint)**: Installed automatically by the workflow (macOS runner)
- **CI (AI Review)**: `ANTHROPIC_API_KEY` secret configured in your repo
- **Local** (optional): `brew install swiftlint`

---

## Sponsor

If Sonar-Swift saves you time, consider [sponsoring](https://github.com/sponsors/Viniciuscarvalho) to support continued development.

---

## License

[MIT](LICENSE) — Vinicius Carvalho
