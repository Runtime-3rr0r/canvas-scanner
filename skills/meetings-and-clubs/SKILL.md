---
name: meetings-and-clubs
description: "Use when processing meetings or org/club context."
---
> **Config**: resolve `<PLACEHOLDER>` tokens from `~/.hermes/school-config.md` (see `canvas-course-sync` → School config). Never edit SKILL.md with real values.


# Meetings & Clubs

## Wispr Flow MCP (meeting transcripts) — search/pull meetings & notes

- Wispr Flow (meeting notetaker) is optional: if configured, Wispr MCP tools appear as `mcp_wispr_*` (search_meetings, get_meeting, search_calendar_events, list_upcoming_meetings, etc.). Configure on a fresh machine via Hermes MCP setup when the user uses Wispr.

- Wispr Flow (meeting notetaker) is optional: if configured, Wispr MCP tools appear as `mcp_wispr_*` (search_meetings, get_meeting, search_calendar_events, list_upcoming_meetings, etc.). Configure on a fresh machine via Hermes MCP setup when the user uses Wispr.

Meeting workflow: search_meetings → get_meeting (summary for action items, transcript for verbatim detail) → save important meetings to `Classes/<Org>/README.md` (e.g. an org folder) with dates/decisions/action items → **add calendar-worthy events to the Roadmap balanced calendar** → update Roadmap. Wispr timestamps are UTC — convert to user's local time before presenting.


## Organization / club context (template)

- <USER_NAME> helps run an <ORG_NAME> (advisor <ORG_ADVISOR>, lead <ORG_LEAD>). He staffs the <ORG_NAME> fair table and does a live demo at the first general meeting. Meeting notes archived in `Classes/<Org>/README.md`. Wispr Flow MCP can be connected for meeting transcripts (see the Wispr section above; fresh machines configure it via Hermes MCP setup).
- Keep any group/organization specifics out of the public suite — this section is a template for whoever installs it.
