---
marp: true
theme: default
paginate: true
title: Task Management Solution
---

<style>
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;700&family=Fira+Code:wght@400;500;700&display=swap');

:root {
  --color-background: #0d1117;
  --color-foreground: #c9d1d9;
  --color-heading: #58a6ff;
  --color-accent: #7ee787;
  --color-code-bg: #161b22;
  --color-border: #30363d;
  --font-default: 'Noto Sans JP', 'Hiragino Kaku Gothic ProN', 'Meiryo', sans-serif;
  --font-code: 'Fira Code', 'Consolas', 'Monaco', monospace;
}

section {
  background-color: var(--color-background);
  color: var(--color-foreground);
  font-family: var(--font-default);
  font-weight: 400;
  box-sizing: border-box;
  border-left: 4px solid var(--color-accent);
  position: relative;
  line-height: 1.6;
  font-size: 20px;
  padding: 56px;
}

h1, h2, h3, h4, h5, h6 {
  font-weight: 700;
  color: var(--color-heading);
  margin: 0;
  padding: 0;
  font-family: var(--font-code);
}

h1 {
  font-size: 52px;
  line-height: 1.3;
  text-align: left;
}

h1::before {
  content: '# ';
  color: var(--color-accent);
}

h2 {
  font-size: 38px;
  margin-bottom: 40px;
  padding-bottom: 12px;
  border-bottom: 2px solid var(--color-border);
}

h2::before {
  content: '## ';
  color: var(--color-accent);
}

ul, ol {
  padding-left: 32px;
}

li {
  margin-bottom: 10px;
}

li::marker {
  color: var(--color-accent);
}

table {
  font-size: 18px;
  border-collapse: collapse;
}

th, td {
  border: 1px solid var(--color-border);
  padding: 8px 12px;
}

th {
  color: var(--color-heading);
  font-family: var(--font-code);
}

pre {
  background-color: var(--color-code-bg);
  border: 1px solid var(--color-border);
  border-radius: 6px;
  padding: 16px;
  overflow-x: auto;
  font-family: var(--font-code);
  font-size: 16px;
  line-height: 1.5;
}

code {
  background-color: var(--color-code-bg);
  color: var(--color-accent);
  padding: 2px 6px;
  border-radius: 3px;
  font-family: var(--font-code);
  font-size: 0.9em;
}

pre code {
  background-color: transparent;
  padding: 0;
  color: var(--color-foreground);
}

section.lead {
  border-left: 4px solid var(--color-accent);
  display: flex;
  flex-direction: column;
  justify-content: center;
}

section.lead h1 {
  margin-bottom: 24px;
}

section.lead p {
  font-size: 22px;
  color: var(--color-foreground);
  font-family: var(--font-code);
}

strong {
  color: var(--color-accent);
  font-weight: 700;
}
</style>

<!-- _class: lead -->

<!--
Presenter note:

Start by framing the demo as a complete, reusable CRUD pattern:

tasks with reusable taxonomies, one contract, several clients, and a working console.
-->

# Task Management Solution

Task workflows with reusable tags and hierarchical classifications, from PostgreSQL to clients and console.

---

<!--
Presenter note:

This is a reference implementation for a real CRUD feature:

small enough to explain, complete enough to show how the stack fits together.
-->

## Purpose

- Demonstrate task management and reusable taxonomy CRUD.
- Keep the public object separate from JPA persistence.
- Share one HTTP contract across Java, TypeScript, and Dart.
- Include a practical React console and bulk data workflows.

---

<!--
Presenter note:

Walk through the runtime stack from API to database, then to clients and console.

Emphasize this is not just backend-only work.
-->

## Runtime

- Spring Boot APIs: `/api/v1/task`, `/api/v1/tag`, `/api/v1/nomenclature`.
- PostgreSQL persistence through Spring Data JPA.
- Java, TypeScript, and Dart clients.
- React, Vite, and MUI management console.
- MkDocs documentation and Marp presentation in the same repo.

---

<!--
Presenter note:

Explain the contract first.

The important design decision is that the public model is stable and intentionally different from the database entity.
-->

## Public Contract

| Field          | Rule                                          |
| -------------- | --------------------------------------------- |
| `id`           | Server-generated `Long`                       |
| `code`         | Required, unique, immutable string            |
| `label`        | Required string                               |
| `description`  | Nullable string                               |
| `status`       | `TODO` / `IN_PROGRESS` / `DONE` / `CANCELLED` |
| `priority`     | `LOW` / `NORMAL` / `HIGH` / `URGENT`          |
| Due / assignee | Nullable `YYYY-MM-DD` date / string           |
| Taxonomy       | `tagIds: []`, nullable `nomenclatureId`       |
| Audit          | Server-owned timestamps and actors            |

Defaults: status `TODO`, priority `NORMAL`, no taxonomy assignment.

---

<!--
Presenter note:

Use this example to show the actual JSON response and call out the immutable code value and timestamp semantics.
-->

## Task

```json
{
  "id": 42,
  "code": "RELEASE-001",
  "label": "Prepare release",
  "description": "Review the release checklist",
  "status": "TODO",
  "priority": "HIGH",
  "dueDate": "2026-11-01",
  "assignedTo": "alice",
  "tagIds": [],
  "nomenclatureId": null,
  "createdDate": "2026-08-30T17:00:00Z",
  "lastModifiedDate": "2026-08-30T17:05:00Z",
  "createdBy": "admin",
  "lastModifiedBy": "alice"
}
```

---

<!--
Presenter note:

This is the main API surface.

Highlight that seed and import are operational shortcuts, while the CRUD endpoints expose the standard model lifecycle.
-->

## API

| Method | Path                                                               |
| ------ | ------------------------------------------------------------------ |
| CRUD   | `/api/v1/task[/{id}]`                                              |
| CRUD   | `/api/v1/tag[/{id}]`                                               |
| CRUD   | `/api/v1/nomenclature[/{id}]`                                      |
| `POST` | `/api/v1/task/seed`                                                |
| `POST` | `/api/v1/task/import.{json,csv}`                                   |
| `GET`  | `/api/v1/task/export.{json,csv}`                                   |
| PDF    | `/api/v1/task/{id}/print.pdf`, `/print.pdf`, `/print-selected.pdf` |

Seed and import upsert by `code` and ignore imported IDs and dates.
Create includes `code`; update excludes immutable `code`.

---

## Reusable Taxonomy Domains

- **Tag**: flat labels shared by tasks, such as Release or Documentation.
- **Nomenclature**: classification tree, such as Engineering → Release.
- Both: `id`, `code`, `label`, `description`, creation/modification dates and actors.
- Nomenclatures add nullable `parentId`; `null` means a root.
- References must exist; self-parenting and hierarchy cycles are rejected.
- Referenced tags, task classifications, and parents with children cannot be deleted.

---

<!--
Presenter note:

Reinforce the architectural boundary:

public domain model vs persistence model.

This keeps the API honest and prevents leaking JPA details.
-->

## Model Boundary

- `Task`, `Tag`, `Nomenclature`: public business objects.
- Internal mutable JPA entities isolate persistence behavior.
- The service maps between public and persistence models.
- Namespace `fr.tiogars.domaintemplate` and artifact identities stay unchanged.

---

<!--
Presenter note:

Mention the demo database setup and the known caveat that the old table is not auto-dropped, so a full volume reset is the cleanest way to start fresh.
-->

## Demo Database

Apply `template-java-api/src/main/resources/db/manual/task-domains.sql` before API startup on an existing database (automatic on a new Dokploy volume).
`ddl-auto: update` is not a data migration and does not remove legacy tables.

```bash
docker compose -f docker/compose.yml -f docker/compose.local.yml down --volumes
docker compose -f docker/compose.yml -f docker/compose.local.yml up -d postgres
```

Resetting the demo volume removes all stored data.
Reapply the task-domain migration, then run `make docker-up`.

---

<!--
Presenter note:

End on the operational path:

start the stack, open API, console, docs, and show that the repo is designed for quick local validation.
-->

## Deploy Quickly

```bash
make docker-up
```

- API: [`http://localhost:8989`](http://localhost:8989)
- Swagger: [`http://localhost:8989/swagger-ui.html`](http://localhost:8989/swagger-ui.html)
- Console: [`http://localhost:5173`](http://localhost:5173)
- Docs: [`http://localhost:8000`](http://localhost:8000)

---

<!--
Presenter note:

The container serves the interactive Bespoke deck plus the exported PDF and PPTX built at image build time.
-->

## Take Away

- Presentation deck: [`http://localhost:8082`](http://localhost:8082)
- PDF: [domaintemplate.pdf](./domaintemplate.pdf)
- PPTX: [domaintemplate.pptx](./domaintemplate.pptx)
- Presenter mode: press `p` on the deck.
