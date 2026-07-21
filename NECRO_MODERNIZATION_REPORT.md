# Awesome Print — Modernization Report (v1.9.2 → v2.0.0)

This PR modernizes `awesome_print` so it installs, runs, tests and lints
cleanly on the current Ruby ecosystem (validated on **Ruby 4.0.5**, and the CI
matrix targets Ruby 2.7–3.4). The gem's public behavior is preserved; the only
intentional behavioral changes are the removal of abandoned ORM integrations
and fixes required by modern Rails.

---

## 1. Dependencies

The gem itself remains **dependency-free at runtime** (it only monkey-patches
the Ruby standard library). All changes are to development/test tooling and to
the optional integrations exercised by the suite.

### gemspec (`awesome_print.gemspec`)
| Dependency | Before | After | Notes |
|---|---|---|---|
| `rspec` | `>= 3.0.0` | `~> 3.13` | current RSpec 3 |
| `sqlite3` | unversioned | `>= 1.4` | resolves to 2.x; used by the ActiveRecord & Sequel specs |
| `nokogiri` | `>= 1.11.0` | `>= 1.11` | dev-only; resolves to a current, CVE-free 1.19.x |
| `appraisal` | present | **removed** | the multi-gemfile Rails matrix was replaced by a single modern stack + CI matrix |
| `fakefs` | `>= 0.2.1` | **removed** | dead dependency — not referenced anywhere in the code or specs |
| `rake` | (implicit) | `~> 13.0` | added explicitly |
| `rubocop` (+ `-rake`, `-rspec`) | — | added | linting |
| `simplecov` | — | `~> 0.22` | coverage enforcement |
| `bundler-audit` | — | `~> 0.9` | dependency CVE auditing |
| `sequel` | — | `~> 5.0` | so the Sequel integration is actually tested |

Also set `required_ruby_version = ">= 2.7"` and added gem `metadata`
(source/changelog/bug-tracker URIs, `rubygems_mfa_required`).

### Gemfile
Rails and Mongoid moved into a `:test` group (`rails >= 6.1`, `mongoid >= 7.0`)
so the ActiveRecord/ActiveSupport/ActionView and Mongoid integrations are
exercised without being forced on end users. `bundle install` resolves cleanly.

### Removed dead integrations
`mongo_mapper`, `ripple` and `nobrainer` are abandoned (no releases in ~a
decade, do not install on modern Ruby). Their extension files **and** specs
were deleted rather than shipped as untested/broken code:

- `lib/awesome_print/ext/{mongo_mapper,ripple,nobrainer}.rb`
- `spec/ext/{mongo_mapper,ripple,nobrainer}_spec.rb`

The remaining, maintained integrations are: **ActiveRecord / ActiveSupport /
ActionView, Mongoid, Sequel, Nokogiri, OpenStruct**.

---

## 2. Compatibility fixes (modern Ruby & Rails)

- **`ActiveModel::Errors#marshal_dump` removed (Rails 7+).** The error formatter
  relied on it and crashed. Rewrote `awesome_active_model_error` to reach the
  base model via its `@base` ivar, and extracted the shared
  `active_record_attributes_hash` helper (removing a copy-paste block).
- **`ActiveSupport::OrderedHash` deprecated.** Replaced all usages in the
  ActiveRecord and Mongoid extensions with plain `Hash` (ordered since Ruby
  1.9); guards changed from `defined?(ActiveSupport::OrderedHash)` to
  `defined?(ActiveSupport)`.
- **`ActiveRecord::Base.default_timezone=` moved to `ActiveRecord.default_timezone=`**
  (Rails 7.1) — updated in the specs.
- **`ActionView::Base.new` signature** (Rails 6.1+) and **`TimeWithZone#inspect`
  format** (Rails 7+) — spec expectations updated for the modern output.
- **`ActiveSupport::BufferedLogger` removed** — dropped the dead `include`; the
  single `Logger.include` already covers `ActiveSupport::Logger` via inheritance.
- **Frozen string literals.** Added `# frozen_string_literal: true` to every
  Ruby file and verified the suite passes with frozen strings (the formatters
  already used `String.new` where mutation is required).
- **Removed dead pre-1.9/legacy shims:**
  - `core_ext/method.rb` (`Method#name` shim for Ruby < 1.8.7) — deleted.
  - `method_tuple`'s pre-1.9.2 `arity`-based branch — removed.
  - `custom_defaults.rb` `diet_rb` (MacRuby/DietRB IRB) — removed.
  - `ObjectFormatter#valid_instance_var?` — unused, removed.
- **StructFormatter bug fix.** Struct members are bare symbols, but the
  formatter treated them like `@`-prefixed ivars (`var.to_s[1..-1]`), mangling
  names and leaving dead accessor-detection branches. Simplified to render
  sorted `member = value` pairs (output unchanged for the existing specs).
- **Sequel dataset formatter.** Was hardcoded to `Sequel::Mysql2::Dataset` (only
  worked under mysql2) and called `awesome_print` — printing to `$stdout` as a
  side effect. Now handles any `Sequel::Dataset` and formats the SQL through the
  inspector without side effects.

No deprecation warnings are emitted by the gem's own code on Ruby 4.0.

---

## 3. Tests & coverage

- Test runner: **RSpec 3**, with **SimpleCov** wired in and
  `minimum_coverage line: 100` enforced (`.simplecov`, which also enables branch
  coverage and `track_files 'lib/**/*.rb'` so every shipped file counts).
- **Coverage: ~91.3% → 100.0% line coverage** (737/737 lines), 207 examples,
  0 failures. Branch coverage is ~85% (the remainder is irreducible: load-time
  `defined?(SomeGem)` optional-integration guards and TTY checks that cannot be
  both-branch-exercised in a single process).
- New / expanded tests:
  - `spec/inspector_spec.rb` — real `~/.aprc` loading, the missing-dotfile and
    error-rescue paths, and forced colorization.
  - `spec/ext/sequel_spec.rb` — model instance, invalid record (errors), model
    class schema, and dataset formatting against an in-memory SQLite DB.
  - ActiveModel::Errors formatting (default and `:raw`) in the AR spec.
  - Self-referential Struct recursion guard.
  - `AwesomePrint.pry!`, `AwesomePrint.version`, and the C-level-proc `grep`
    branch (`&:to_s`) that triggers the eval rescue.
- ActiveRecord raw-dump golden fixtures regenerated for Rails 7+/8
  (`spec/support/active_record_data/7_0_{diana,multi}.txt`), captured in-harness
  and verified deterministic across runs. A `GEN_AR_FIXTURE`-gated hook in the
  spec documents how to regenerate them for future Rails versions.

---

## 4. Documentation

- Added YARD-style inline documentation to the public API: `Kernel#ai`/`#ap`,
  `AwesomePrint` module config helpers, `Inspector`, `Formatter`, `Indentator`,
  the `Colorize` mixin, `BaseFormatter`, and each concrete formatter class.
- **README** refreshed: GitHub Actions badge (Travis/CodeClimate/Gitter badges
  removed), modern install instructions (`gem`/`Gemfile`), corrected supported
  Ruby/Rails versions, and the removal of the dead ORM integrations. Fixed the
  stale `ActiveSupport::BufferedLogger` reference.
- **CONTRIBUTING.md** updated to the `bundle exec rake` / `rspec` workflow
  (dropping the removed Appraisal instructions) and documents the 100%-coverage
  and RuboCop gates.
- **CHANGELOG.md** given a 2.0.0 entry.

---

## 5. Lint & formatting

- Added a modern `.rubocop.yml` (`rubocop` + `rubocop-rake` + `rubocop-rspec`,
  `TargetRubyVersion: 2.7`), tuned for this metaprogramming-heavy gem (metric
  cops relaxed; monkey-patch/OpenStruct/class-var cops that fight the design
  disabled; long golden-output strings in specs exempt from `LineLength`).
- `bundle exec rubocop`: **no offenses** across 59 files. The single
  `eval` (used only to populate `$~`/`$1` for user grep blocks, on escaped
  method-name input) is scoped-disabled with an explanatory comment.
- Replaced the Appraisal-based `Rakefile` with RSpec + RuboCop rake tasks.

---

## 6. Security

- **`bundler-audit`: no vulnerabilities** in the resolved dependency graph.
  (The old gemspec's `nokogiri >= 1.11.0` floor allowed versions with known
  CVEs; the modern resolution pulls a current, patched Nokogiri.)
- **`brakeman`**: not applicable — Brakeman targets Rails applications, not
  libraries (it refuses to scan a plain gem). Noted for completeness.
- Reviewed the two "dangerous" spots: the `Dir`/`File` formatters shell out to
  `ls` but already use `Shellwords#shellescape`; the `grep` `eval` operates on
  the object's own method names with `/` escaped. Both are safe; the `eval` is
  documented inline.
- Added `.github/workflows/ci.yml` running tests (Ruby 2.7–3.4), RuboCop and
  `bundler-audit` on every push/PR.

---

## Verification summary

```
bundle install     → resolves (13 deps, lockfile committed-out per gem convention)
gem build          → awesome_print 2.0.0 built successfully
bundle exec rspec  → 207 examples, 0 failures, 100.0% line coverage
bundle exec rubocop→ 59 files, no offenses
bundler-audit      → No vulnerabilities found
```
