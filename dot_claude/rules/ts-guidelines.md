---
paths:
  - "**/*.{ts,tsx}"
---

# TypeScript Coding Guidelines

## Core Principles

- Use TypeScript for all codebases that contain JavaScript
- **`strict: true`** must always be enabled
- Avoid classes that encapsulate state; prefer functions (unless meaningful state management or dependency injection is needed)

## Type System

### Avoid any, narrow with unknown

```typescript
// Bad - any
catch (error: any) {
  console.log(error.message)
}

// Good
catch (error: unknown) {
  if (error instanceof Error) {
    console.log(error.message)
  } else if (typeof error === "object" && error !== null && "message" in error) {
    console.log((error as { message: string }).message)
  } else {
    console.log(String(error))
  }
}
```

### Type vs Interface

- **Object shapes**: use `interface`
- **Primitives, Unions, Tuples**: use `type`

```typescript
// Object shape -> interface
interface User {
  id: string
  name: string
}

// Union/Primitive -> type
type Status = "pending" | "success" | "error"
type ID = string | number
```

### Leverage Type Inference

Omit type annotations where inference is sufficient:

```typescript
// Good
const items = [1, 2, 3]
const user = { name: "John", age: 30 }

// Bad - redundant
const items: number[] = [1, 2, 3]
```

### Leverage Utility Types

`Partial<T>`, `Required<T>`, `Pick<T, K>`, `Omit<T, K>`, `Record<K, V>`, `ReturnType<T>`

When only a subset of properties is needed, use `Pick` to accept only the required ones:

```typescript
interface User {
  id: string
  name: string
  email: string
}

function findUser({ id }: Pick<User, "id">) {
  // ...
}
```

## Type Assertions & Type Guards

### Prefer Type Guards

Use type assertions (except const assertions) only when unavoidable:

```typescript
// Good - type guard
if (value instanceof Error) {
  // value is Error
}

// Avoid - type assertion
const error = value as Error
```

### Type Guard Functions

Extract complex or reusable narrowing into functions:

```typescript
function isKeyboardEvent(event: Event): event is KeyboardEvent {
  return "key" in event
}
```

### Non-Null Assertion

Avoid `!` by default; prefer proper null checks. However, after a guard (`if` existence check), use `!` and skip redundant fallbacks:

```typescript
// Bad - unguarded !
const name = user!.name

// Good - null check
const name = user?.name ?? "Anonymous"

// Good - after guard, use ! for brevity
if (data.items == null) return;
const items = data.items!;  // no fallback needed

// Bad - redundant fallback after guard
if (data.items == null) return;
const items = data.items || { ids: [], byId: {} };  // unreachable branch
```

## Avoid enum

Use literal types with const assertions, or union types:

```typescript
// Good
const STATUS = {
  Loading: "loading",
  Success: "success",
  Error: "error",
} as const

type Status = (typeof STATUS)[keyof typeof STATUS]

// Also Good - for simple cases
type Status = "loading" | "success" | "error"

// Bad
enum Status {
  Loading = "loading",
  Success = "success",
  Error = "error",
}
```

## Discriminated Unions

Use a discriminator field when union narrowing becomes complex:

```typescript
type Shape =
  | { kind: "circle"; radius: number }
  | { kind: "square"; size: number }

function area(shape: Shape): number {
  switch (shape.kind) {
    case "circle":
      return Math.PI * shape.radius ** 2
    case "square":
      return shape.size ** 2
  }
}
```

## Functions

### Options Object Pattern

When a function has multiple parameters, group them into an object and extract the type as an interface:

```typescript
// Good - extracted type
interface CreateUserOptions {
  name: string
  email: string
  role?: string
}

function createUser(options: CreateUserOptions) {
  // ...
}

// Bad - positional arguments
function createUser(name: string, email: string, role?: string) {
  // ...
}

// Bad - inline type (hard to reuse/extend)
function createUser(options: { name: string; email: string; role?: string }) {
  // ...
}
```

### Arrow Functions

- Callbacks and short functions: arrow function
- Method definitions: shorthand method syntax

```typescript
// Callbacks
items.filter((item) => item.active)

// Object methods
const service = {
  fetch() {
    return api.get("/data")
  },
}
```

### Return Types

- Public API: annotate explicitly
- Internal functions: let inference handle it

## Error Handling

### Result Pattern

Consider a Result type instead of exceptions:

```typescript
type Result<T, E = Error> = { ok: true; value: T } | { ok: false; error: E }

function parseJson(text: string): Result<unknown> {
  try {
    return { ok: true, value: JSON.parse(text) }
  } catch (error) {
    return { ok: false, error: error instanceof Error ? error : new Error(String(error)) }
  }
}
```

## Async/Await

- Prefer async/await over Promise chains
- Use `Promise.all()` / `Promise.allSettled()` for parallel execution

```typescript
// Parallel execution
const [users, posts] = await Promise.all([fetchUsers(), fetchPosts()])
```

## Modern Syntax

### Optional Chaining & Nullish Coalescing

```typescript
// Good
const name = user?.profile?.name ?? "Anonymous"

// Bad
const name = user && user.profile && user.profile.name ? user.profile.name : "Anonymous"
```

### ES Modules

```typescript
// Prefer named exports
export { UserService, createUser }

// Avoid default exports (hard to track during refactoring)
```

## Import Order

1. Node.js built-in modules
2. External packages
3. Internal modules (absolute path)
4. Relative imports

```typescript
import { readFile } from "node:fs/promises"

import { z } from "zod"

import { config } from "@/config"

import { helper } from "./helper"
```

## Naming Conventions

> **Note**: Adopt these for new projects. For existing projects, follow their established conventions.

| Category | Convention | Example |
|----------|-----------|---------|
| Variables & functions | camelCase | `getUserById` |
| Classes, types & interfaces | PascalCase | `UserService` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT` |
| Booleans | is/has/can prefix | `isActive`, `hasPermission` |
| Private | `#` prefix (ES2022) | `#cache` |

## References

- https://google.github.io/styleguide/tsguide.html
