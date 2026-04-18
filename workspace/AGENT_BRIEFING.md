# Agent Briefing

> This file is read by the agent at startup as environment context. Fill in
> the slots that apply to your deployment; delete ones that don't.

## Environment

| Property | Value |
|----------|-------|
| Runtime | ZeroClaw gateway on port 18789 (default) |
| Host | <where this agent runs: k8s cluster / VPS / laptop> |
| State | `~/.pioneer/agents/<agent-id>/workspace/` (or PVC in k8s) |
| Access | <internal only / public via tunnel / paired gateway> |

## Identity Summary

_Short version of `workspace/IDENTITY.json` — single paragraph, plain language._

## Mission

_One to three sentences: what this agent exists to do._

## Tools

Tool definitions live in `tools.d/`. Groups are defined in
`tools.d/registry.toml` and loaded on demand via progressive disclosure.

Currently enabled groups:

- _(list the groups your agent actually uses)_

## External APIs

_If your agent talks to internal services, document them here so the model has
context. Format: table of endpoint + auth + purpose._

| Endpoint | Auth Header | Purpose |
|----------|-------------|---------|
| _..._ | _..._ | _..._ |

## Standing Instructions

_Behavior rules that apply to every turn regardless of input. Keep this short
— heavy rules belong in SOUL.md._

1. _..._
2. _..._

## Escalation

_When does this agent defer to a human? Who is that human? How do they get
notified?_
