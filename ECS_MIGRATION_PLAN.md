# ECS Migration Plan: `part_13` → `echosinthedark-godot`

This document tracks the migration of the Entity-Component-System (ECS) architecture from `part_13` into `echosinthedark-godot`.

---

## **Overview**

We are migrating to an ECS architecture to improve modularity, maintainability, and extensibility. This plan outlines the steps, tasks, and progress tracking for the migration.

---

## **Migration Steps**

### 1. Preparation
- [ ] **Review ECS Structure in `part_13`**
  - Identify all relevant files: `src/Entities/`, `src/Entities/Actors/Components/`, `src/Entities/Actors/Actions/`, `src/Utils/`, and `assets/definitions/`.
- [ ] **Review Current Architecture in `echosinthedark-godot`**
  - List scripts and systems to be replaced or refactored (e.g., `pc_action.gd`, `actor_action.gd`).

### 2. Copy ECS Files
- [ ] **Copy ECS Source Files**
  - [ ] Copy `src/Entities/` to `echosinthedark-godot/src/ECS/Entities/`
  - [ ] Copy `src/Utils/` to `echosinthedark-godot/src/ECS/Utils/`
  - [ ] Copy `src/Entities/Actors/Components/` to `echosinthedark-godot/src/ECS/Entities/Actors/Components/`
  - [ ] Copy `src/Entities/Actors/Actions/` to `echosinthedark-godot/src/ECS/Entities/Actors/Actions/`
- [ ] **Copy Definitions**
  - [ ] Copy `assets/definitions/` to `echosinthedark-godot/resource/definitions/` (or similar)

### 3. Integrate ECS into Game Logic
- [ ] **Update Project Settings**
  - [ ] Update `project.godot` paths and autoloads if necessary.
- [ ] **Refactor Player Logic**
  - [ ] Refactor `pc_action.gd` to use ECS entities and components.
- [ ] **Refactor Enemy Logic**
  - [ ] Refactor `actor_action.gd` and related scripts to ECS.
- [ ] **Refactor Item Logic**
  - [ ] Migrate item handling to ECS.
- [ ] **Integrate Actions/Systems**
  - [ ] Replace direct method calls with ECS actions/systems.

### 4. Testing & Debugging
- [ ] **Test After Each Major Step**
  - [ ] Run the game and fix issues after each refactor.
- [ ] **Debug and Validate**
  - [ ] Ensure all features work as expected.

### 5. Cleanup
- [ ] **Remove Old Code**
  - [ ] Delete or archive scripts and systems replaced by ECS.
- [ ] **Document New Architecture**
  - [ ] Update or create documentation for the new ECS system.

---

## **Progress Tracking**

- Use checkboxes above to track completed steps.
- Add notes, blockers, or questions below as needed.

---

## **Notes & Questions**

- _Add any migration notes, design decisions, or open questions here._
