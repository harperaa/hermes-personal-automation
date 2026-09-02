---
name: sunday-kitchen
description: Plan a week of dinners from what is already in the fridge, prioritising what expires soonest, and produce a shopping list for only the gap.
version: 1.0.0
author: Allen Harper
metadata:
  hermes:
    tags: [blueprint, food, planning, level-6]
    requires_toolsets: [file]
    config:
      - key: sunday_kitchen.inventory_path
        default: "~/life/kitchen/inventory.md"
        description: Fridge/pantry inventory
        prompt: Fridge/pantry inventory
      - key: sunday_kitchen.preferences_path
        default: "~/life/kitchen/preferences.md"
        description: Dislikes, constraints, equipment
        prompt: Dislikes, constraints, equipment
      - key: sunday_kitchen.meals
        default: "5"
        description: Dinners to plan per week
        prompt: Dinners to plan per week
    blueprint:
      schedule: "0 10 * * 0"
      deliver: origin
      prompt: "Plan the coming week's dinners and give me the shopping list."
      no_agent: false
---

# Sunday Kitchen (Level 6)

## When to Use
Weekly, when planning meals or a shop. Also on demand for "what should I cook tonight".

## Inputs
- `inventory_path` - one item per line: `item — quantity — expiry`
- `preferences_path` - dislikes, dietary constraints, equipment available, rotation rules

## Procedure
1. Read both files. If inventory is missing or empty, say so and stop - do not invent contents.
2. Sort inventory by expiry, soonest first.
3. Propose `meals` dinners. Each must use at least two items from the top third of that sorted list.
4. Respect every constraint in preferences without exception.
5. Produce a shopping list of only what those dinners need beyond current inventory, grouped by aisle.
6. Cap each recipe description at two sentences.

## Pitfalls
- Do not repeat a main protein more than twice in one week.
- Do not suggest anything requiring equipment not listed in preferences.
- If two constraints conflict, name both and ask - do not silently pick one.
- Never assume a staple is present. If it is not in inventory, it goes on the list.

## Verification
Every proposed dinner traces to at least two named inventory items, and nothing on the shopping list is already in the fridge.
