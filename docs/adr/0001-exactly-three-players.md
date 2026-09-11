---
status: accepted
---

# Exactly three players, as a hard constraint

Every test is played by exactly three humans: no solo, no two or four, no AI teammate, no bot filling an empty seat. The asymmetric role split (each role holding an ingredient the others lack) is the whole game, and it only produces the intended chaos when the number of roles is fixed and every one of them is a person. Scaling the count is the most-cited complaint about BOMBANANA and also part of why that game works; we make the same trade.

## Consequences

- Every vehicle must produce a role split in which each of three roles is necessary to pass. A vehicle that plays fine with two is not finished.
- The lobby holds exactly three and waits. Matchmaking, drop-in, and reconnect all assume the seat count is three.
- Playtesting requires three people. Budget for it; there is no single-player debug mode that tells you whether the design is funny.
