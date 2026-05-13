# Extraction Guide — Finding Domain Terms in a Codebase

This guide is used by `ywc-ubiquitous-language` in `extract` mode to discover candidate domain terms from an existing codebase.

## Extraction Philosophy

Not every class name is a domain term. The goal is to find names that represent **business concepts**, not technical plumbing. A `UserRepository` is a technical artifact; `User` and `Order` are domain concepts.

| Signal | Interpretation |
|---|---|
| Appears in domain/business layer, has meaningful state, appears in requirements | Likely domain term |
| Has suffix Controller, Repository, Handler, Middleware, DAO, DTO, Mapper | Likely plumbing |

---

## Step 1: Locate Domain Layer Files

Scan for directories and files that indicate domain logic:

```bash
find . -type d \( \
  -name "domain" -o \
  -name "model" -o \
  -name "models" -o \
  -name "entity" -o \
  -name "entities" \
\) | grep -v node_modules | grep -v .git

find . -type d \( \
  -name "aggregate" -o \
  -name "valueobject" -o \
  -name "vo" \
\) | grep -v node_modules | grep -v .git
```

---

## Step 2: Extract Class, Struct, and Type Names

Prefer `rg` when available.

### TypeScript / JavaScript

```bash
rg -n "^(export )?(class|interface|type|enum) " src app lib \
  -g "*.ts" -g "*.tsx" \
  -g "!*.spec.*" -g "!*.test.*"
```

Exclude names containing `Controller`, `Repository`, `Service`, `Handler`, `Middleware`, `DTO`, `Mapper`, `Factory`, or `Builder` unless the user confirms they are domain terms.

### Python

```bash
rg -n "^class " src app domain -g "*.py" -g "!test_*"
```

Exclude `Test`, `Controller`, `Repository`, `Service`, `Handler`, and `Middleware` names by default.

### Go

```bash
rg -n "^type .* (struct|interface)" . -g "*.go" -g "!*_test.go"
```

Exclude `Repository`, `Handler`, `Controller`, `Middleware`, and `DAO` names by default.

### Kotlin / Java

```bash
rg -n "^(data class|class|interface|enum class) " src -g "*.kt" -g "*.java"
```

Exclude `Test`, `Controller`, `Repository`, `Service`, `Handler`, `DTO`, and `Mapper` names by default.

### Ruby

```bash
rg -n "^class " app/models app/domain -g "*.rb"
```

Exclude test and spec paths by default.

---

## Step 3: Extract Enum Values

Enum values often surface Domain Events and state transitions:

```bash
rg -n "= ['\"]|status|state|type|event" src -g "*.ts" -g "*.tsx"
rg -n "class.*Enum" src -g "*.py"
```

---

## Step 4: Scan Comments and Docstrings

Domain terms often appear in comments near class definitions:

```bash
rg -n "^\s*/\*\*|^\s*\* " src -g "*.ts" -g "*.tsx"
rg -n '"""' src -g "*.py"
```

---

## Step 5: Check Schema Definitions

If the project has API or database schemas, they often reflect canonical domain models:

```bash
find . -name "openapi.yaml" -o -name "openapi.json" -o -name "swagger.yaml"
find . \( -name "schema.prisma" -o -name "*.schema.ts" -o -name "*.entity.ts" \) | grep -v node_modules
```

---

## Step 6: Cluster by Module Path

Group candidates by top-level module/package. Each group is a Bounded Context candidate.

| Candidate Terms | Source Path | Context Candidate |
|----------------|-------------|------------------|
| Order, OrderItem, Cart | `src/order/` | Order |
| Payment, Invoice, Refund | `src/payment/` | Payment |
| Product, Category, Catalog | `src/catalog/` | Catalog |
| User, Profile, Address | `src/user/` | Identity |

---

## Noise Filter

| Pattern | Example | Reason |
|---------|---------|--------|
| Infrastructure suffixes | `OrderRepository`, `PaymentGateway` | Technical artifact, not domain vocabulary |
| Controller/Handler/Middleware | `OrderController` | Presentation or transport layer |
| DTO/Request/Response | `CreateOrderRequest` | Transport shape, not business concept |
| Test classes | `OrderTest`, `MockPayment` | Test artifact |
| Generic utilities | `BaseEntity`, `AbstractModel` | Framework boilerplate |
| Pure config | `DatabaseConfig`, `AppSettings` | Not a domain concept |

---

## User Confirmation Format

After extraction, present candidates as a table grouped by context:

```markdown
Found the following domain term candidates:

## Order Context (`src/order/`)

| Candidate | Source | Recommendation |
|-----------|--------|----------------|
| Order | `order.entity.ts:5` | Keep |
| OrderItem | `order-item.value-object.ts:3` | Keep |
| OrderStatus | `order-status.enum.ts:1` | Confirm |

## Payment Context (`src/payment/`)

| Candidate | Source | Recommendation |
|-----------|--------|----------------|
| Payment | `payment.entity.ts:7` | Keep |
| Invoice | `invoice.entity.ts:2` | Confirm |

Please confirm which terms to include. For each confirmed term, I will ask for definition, Korean equivalent, and synonyms to avoid.
```
