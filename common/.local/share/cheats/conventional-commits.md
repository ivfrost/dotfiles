# Conventional Commits — Full Reference

```
<type>(<optional scope>): <description>

<optional body>

<optional footer(s)>
```

## Types

### `feat` — new feature
```
feat: add dark mode toggle
feat(auth): add refresh token rotation
```

### `fix` — bug fix
```
fix: prevent crash on empty input
fix(api): correct null pointer in device mapper
```

### `docs` — documentation only
```
docs: add setup instructions to README
docs(readme): fix broken install link
```

### `style` — formatting, no logic change
```
style: apply prettier to src/
style(devices): reindent DeviceService
```

### `refactor` — code change, no fix or feature
```
refactor: extract validation into helper
refactor(auth): simplify token refresh flow
```

### `perf` — performance improvement
```
perf: cache device lookups
perf(api): reduce N+1 queries in getDevicesByUserId
```

### `test` — adding/fixing tests
```
test: add unit tests for login flow
test(devices): cover admin update path
```

### `build` — build system or dependencies
```
build: bump spring boot to 4.0.1
build(deps): update mapstruct to 1.6.3
```

### `ci` — CI config/scripts
```
ci: cache maven deps between runs
ci(actions): add lint step to pipeline
```

### `chore` — maintenance, tooling
```
chore: update .gitignore
chore(release): bump version to 1.2.0
```

### `revert` — reverts a previous commit
```
revert: feat(auth): add refresh token rotation
```
> git creates this automatically with `git revert <hash>`

---

## The Body — how to write one

The body explains **why**, not what (the diff already shows what).
Use it when the subject line alone doesn't give enough context for
someone reading `git log` six months from now.

**Rules:**
- blank line between subject and body (required)
- wrap at ~72 chars per line (git log/GitHub don't wrap for you)
- imperative present tense, same as the subject
  (`fix bug`, not `fixed bug` / `fixes bug`)
- can be one paragraph, several paragraphs, or a bullet list

### Example: single paragraph body
```
fix(devices): correct cache eviction on admin reassignment

Previously the cache was evicted for requestingUserId even when an
admin reassigned a device to a different user. This left the new
owner's device list cache stale until the next unrelated write.
```

### Example: multi-paragraph body
```
refactor(auth): split doUpdateDeviceDetails into admin and user paths

The single method relied on a caller-supplied isAdmin flag, which
meant nothing prevented a caller from invoking the "admin" path with
isAdmin=false and silently hitting the access-denied branch instead
of a compile-time guarantee.

Two entry points now hardcode isAdmin at the call site instead, so
the method name and its guaranteed behavior always match.
```

### Example: body as a bullet list (good for multi-part changes)
```
feat(devices): add admin device reassignment

- add newUserId param to updateDeviceDetailsAdmin
- guard non-admin callers from setting technicalName/firmware/userId
- evict new owner's cache on reassignment, fall back to original
  owner otherwise
- add @Size constraints matching entity column limits
```

### Example: body explaining a non-obvious decision
```
fix(mapper): stop MapStruct from double-setting restricted fields

MapStruct's null-check mapper was overwriting technicalName after
the manual ownership guard already validated it. Adding
@Mapping(target = "technicalName", ignore = true) keeps the manual
validation as the single source of truth for that field, same for
firmware and userId.
```

---

## Footers

Footers go after the body (blank line before them), one per line,
using a `Token: value` or `Token #value` format.

### Reference an issue without closing it
```
fix(api): handle null MAC address in provisioning

Refs: #142
```

### Close an issue automatically (GitHub/GitLab keywords)
```
feat(devices): add device unlink endpoint

Closes #98
```

### Multiple footers together
```
fix(auth): resolve token refresh race condition

The refresh call could fire twice under concurrent requests, causing
one of them to receive an already-rotated (invalid) token.

Refs: #201
Reviewed-by: teammate-name
Closes #187
```

### Breaking change via footer (use when it needs explaining)
```
feat(auth): rotate refresh tokens on every use

Refresh tokens are now single-use. Reusing an old token after a
refresh returns 401 instead of a new token pair.

BREAKING CHANGE: clients must handle 401 on refresh and
re-authenticate instead of retrying with the same token.
```

### Breaking change shorthand (use when no extra explanation needed)
```
feat!: drop support for Node 16
feat(auth)!: require MFA on login
```

---

## Writing a real multi-line commit

Don't try to cram body/footer into `-m` flags by hand — it's fragile.
Just run:

```
git commit
```

with no `-m` at all. This opens `$EDITOR`, where you type the whole
thing freely: subject line, blank line, body (paragraphs or bullets),
blank line, footers. Save and close — git handles the rest.

---

Full spec: <https://www.conventionalcommits.org/en/v1.0.0/>
