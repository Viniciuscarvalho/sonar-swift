# 🔍 Sonar-Swift

Estrutura plugável de SwiftLint para projetos iOS — roda no GitHub CI em todo PR.

## Quick Start

```bash
curl -sL https://raw.githubusercontent.com/Viniciuscarvalho/sonar-swift/main/bin/install.sh | bash
```

Ou manualmente:

```bash
git clone https://github.com/Viniciuscarvalho/sonar-swift.git /tmp/sonar-swift
cp /tmp/sonar-swift/.swiftlint.yml .
cp -r /tmp/sonar-swift/.github .
rm -rf /tmp/sonar-swift
```

## O que é instalado

| Arquivo | Função |
|---|---|
| `.swiftlint.yml` | Regras compartilhadas de lint |
| `.github/workflows/swiftlint.yml` | CI que roda SwiftLint em todo PR |
| `.github/workflows/swift-review.yml` | CI que posta report de lint como comment no PR |

## Como funciona

Ao abrir ou atualizar um PR com arquivos `.swift`, dois jobs rodam automaticamente:

1. **SwiftLint** — valida contra as regras do `.swiftlint.yml` com `--strict`. Erros aparecem inline no diff do PR.
2. **Swift Review** — roda lint nos arquivos alterados e posta um report consolidado como comentário no PR.

Nada roda localmente a não ser que você queira (`swiftlint lint`).

## Customizar regras

Edite o `.swiftlint.yml` no seu projeto. As regras padrão cobrem:

- Line length: 140 warning / 200 error
- `force_unwrapping` e `implicitly_unwrapped_optional` habilitados
- `cyclomatic_complexity`: 10 warning / 20 error
- Modifier order enforçado
- Identificadores curtos permitidos: `id`, `x`, `y`, `vm`, `vc`, `db`, etc.

## Requisitos

- **CI**: SwiftLint instalado automaticamente pelo workflow (macOS runner)
- **Local** (opcional): `brew install swiftlint`
