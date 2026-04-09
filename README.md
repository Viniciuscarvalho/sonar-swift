<p align="center">
  <strong>Sonar-Swift</strong><br>
  Pluggable SwiftLint CI for iOS projects — shared rules + GitHub Actions workflows.
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-ffd60a?style=flat-square" alt="MIT License"></a>
  <a href="https://github.com/Viniciuscarvalho/sonar-swift/actions"><img src="https://img.shields.io/badge/CI-GitHub_Actions-2088FF?style=flat-square&logo=github-actions&logoColor=white" alt="GitHub Actions"></a>
  <a href="https://realm.github.io/SwiftLint/"><img src="https://img.shields.io/badge/SwiftLint-strict-ff6b6b?style=flat-square" alt="SwiftLint"></a>
  <a href="#"><img src="https://img.shields.io/badge/Platform-iOS_17+-000000?style=flat-square&logo=apple&logoColor=white" alt="iOS 17+"></a>
  <a href="https://github.com/sponsors/Viniciuscarvalho"><img src="https://img.shields.io/badge/Sponsor-%E2%9D%A4-ea4aaa?style=flat-square&logo=github-sponsors&logoColor=white" alt="Sponsor"></a>
</p>

---

## What It Does

Sonar-Swift is a **plug-and-play SwiftLint setup** for any iOS project. Install it once and every PR gets automatic lint checks with inline annotations and a consolidated review comment.

- **Zero config** — works out of the box with sensible defaults
- **Two CI workflows** — strict lint + PR review comment
- **One-line install** — `curl` script copies everything you need
- **Customizable** — override any rule in your local `.swiftlint.yml`

---

## Quick Start

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

---

## What Gets Installed

| File                                 | Purpose                                            |
| ------------------------------------ | -------------------------------------------------- |
| `.swiftlint.yml`                     | Shared lint rules                                  |
| `.github/workflows/swiftlint.yml`    | CI that runs SwiftLint on every PR with `--strict` |
| `.github/workflows/swift-review.yml` | CI that posts a lint report as a PR comment        |

---

## How It Works

When you open or update a PR with `.swift` files, two jobs run automatically:

1. **SwiftLint** — validates against `.swiftlint.yml` rules with `--strict`. Errors appear inline in the PR diff.
2. **Swift Review** — runs lint on changed files and posts a consolidated report as a PR comment.

Nothing runs locally unless you want it to (`swiftlint lint`).

---

## Default Rules

| Rule                  | Warning | Error |
| --------------------- | ------- | ----- |
| Line length           | 140     | 200   |
| File length           | 500     | 1000  |
| Function body length  | 50      | 100   |
| Cyclomatic complexity | 10      | 20    |
| Type body length      | 300     | 500   |

Plus: `force_unwrapping`, `implicitly_unwrapped_optional`, `modifier_order`, and [20+ opt-in rules](.swiftlint.yml).

---

## Customization

Edit `.swiftlint.yml` in your project to override any rule. The defaults target iOS 17+ / SwiftUI projects.

---

## Requirements

- **CI**: SwiftLint is installed automatically by the workflow (macOS runner)
- **Local** (optional): `brew install swiftlint`

---

## Sponsor

If Sonar-Swift saves you time, consider [sponsoring](https://github.com/sponsors/Viniciuscarvalho) to support continued development.

---

## License

[MIT](LICENSE) — Vinicius Carvalho
