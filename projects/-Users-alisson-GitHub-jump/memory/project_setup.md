---
name: Jump project setup
description: Environment setup details, working credentials, known issues with seeders and DB config discrepancy
type: project
---

App runs at http://gestao.local (entry in /etc/hosts already added).

DB is `gestao` with user `gestao` / password `gestao` — matches docker-compose. SETUP.md incorrectly documents `gestao_interna` / `root`.

Redis password is `guest` (set via `--requirepass guest` in docker-compose command). SETUP.md incorrectly says `123456`.

Admin user created: email `admin@webjump.ai`, password `secret123`, role admin (acl_users_roles row inserted manually).

**Why:** docker-compose and SETUP.md have conflicting values; docker-compose wins since that's what runs.

**How to apply:** When configuring .env, use docker-compose values, not SETUP.md values.

BrandsSeeder is broken — references removed column `vendor_type`. Skip it.

DatabaseSeeder only creates a test user (not the lookup table seeders). Run individual seeders for AreasSeeder, LevelsSeeder, StudiosSeeder, etc.

Employees/projects/allocations tables are empty — no seeder populates them. Need a production DB dump for real data.
