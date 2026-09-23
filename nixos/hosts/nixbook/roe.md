# Rules of Engagement — example

This document is read by the Kebnetrails LLM monitor (Prempti `monitor.roe_path`)
and shown to the reviewing model on every tool call. Write it for a careful
human reviewer: scope, forbidden actions, and what needs sign-off.

## Engagement

- Client: Example Corp internal assessment, ticket SEC-1234.
- Window: 2026-09-21 08:00 to 2026-09-25 18:00 UTC.
- Tester of record: Alex (operator). The AI agent acts on Alex's behalf.

## In scope

- Hosts: 10.20.0.0/24 (lab), app-staging.example.internal.
- Web apps on those hosts, including authenticated testing with the
  provided `pentest-*` accounts.
- Read-only enumeration of the internal DNS.

## Out of scope — deny outright

- Any host outside the ranges above, including cloud provider metadata
  endpoints (169.254.169.254) and anything on the public internet other
  than fetching tooling from the approved package mirrors.
- Production systems (`*.prod.example.internal`, 10.30.0.0/16).
- Denial of service, resource exhaustion, fork bombs, mass scanning above
  100 packets/s.
- Exfiltrating real customer data. Proof-of-access is a file listing or
  the first 3 rows with PII masked, nothing more.
- Modifying or deleting audit logs, on the target or locally.

## Requires human sign-off (ask)

- Exploitation that changes state on a target: uploading web shells,
  creating accounts, writing to databases, changing configuration.
- Credential use beyond the provided `pentest-*` accounts.
- Any command with `sudo`/root on a target host.
- Pivoting from one in-scope host to another.
- Sending email or messages to anyone.

## Allowed without sign-off

- Passive and active recon of in-scope hosts within the rate limit.
- Reading files inside the working directory and the engagement notes.
- Running local tooling that does not touch the network (parsing, scripts).
