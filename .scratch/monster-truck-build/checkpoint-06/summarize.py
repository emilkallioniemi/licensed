#!/usr/bin/env python3
"""Summarize captured observations; missing values remain null, never inferred zero."""
import json
import math
import sys
from pathlib import Path


def distribution(values):
    values = sorted(v for v in values if v is not None)
    if not values:
        return None
    return {"count": len(values), **{f"p{p}": values[max(0, math.ceil(len(values)*p/100)-1)] for p in (50, 95, 99)}, "max": values[-1]}


summaries = []
for name in sys.argv[1:]:
    rows = []
    invalid = 0
    for line in Path(name).read_text().splitlines():
        try:
            rows.append(json.loads(line))
        except json.JSONDecodeError:
            invalid += 1
    frames = [v for r in rows if r["event"] == "frames" for v in r["intervals_ms"]]
    replies = [r for r in rows if r["event"] == "probe_reply"]
    timeouts = sum(r["event"] == "probe_timeout" for r in rows)
    resolved = len(replies) + timeouts
    corrections = [r for r in rows if r["event"] == "reconciliation"]
    active_seconds = sum(sum(r["intervals_ms"])/1000 for r in rows if r["event"] == "frames" and r["active"])
    summaries.append({
        "file": name, "malformed_lines": invalid,
        "frame_ms": distribution(frames),
        "application_rtt_ms": distribution([r["rtt_ms"] for r in replies]),
        "successive_rtt_delta_ms": distribution([r["successive_rtt_delta_ms"] for r in replies]),
        "resolved_probes": resolved, "timeout_fraction": timeouts/resolved if resolved else None,
        "unresolved_probes": sum(r["event"] == "probe_sent" for r in rows)-resolved,
        "transport_packet_loss": None,
        "input_ack_age_ms": distribution([r["ack_age_ms"] for r in corrections]),
        "learner_reconciliation_m": distribution([r["learner_distance_m"] for r in corrections]),
        "active_seconds": active_seconds,
        "large_corrections_per_active_second": sum(r["large_correction"] for r in corrections)/active_seconds if active_seconds and corrections else None,
        "all_reconciliations_per_active_second": len(corrections)/active_seconds if active_seconds and corrections else None,
        "input_to_visible_response_ms": None,
    })

print(json.dumps(summaries, indent=2))
