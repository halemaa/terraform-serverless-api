# 2. What is "serverless"?

## The name is misleading

"Serverless" does **not** mean there are no servers. There are — you just don't
own, rent, patch, or manage them. AWS runs them, and hands you the result.

The taxi analogy:
- **Traditional server (e.g. EC2):** owning a car. You buy it, fuel it, service
  it, insure it — and it sits in the driveway doing nothing most of the day. You
  pay whether you drive or not.
- **Serverless:** taking a taxi. It appears when you need it, you pay only for
  the trip, and you never think about maintenance. No trips → no cost.

For a low-traffic app (like a portfolio project), the taxi wins massively: an
idle serverless app costs about **$0**, while an idle server still bills by the
hour.

## The three pieces in this project

Using the restaurant analogy:

### API Gateway — the front desk
The public web address people actually visit. It receives HTTP requests
(`GET /items`, `POST /items`), checks them, and passes them to the right worker.
It's the only part exposed to the internet.

### AWS Lambda — the chef
A small piece of code that wakes up **only when there's an order**, cooks one
dish (handles one request), and goes back to sleep. Billed per run, in
milliseconds. This holds your actual logic — "save this note," "fetch that one."
In this repo, that code is [`src/handler.py`](../src/handler.py).

### DynamoDB — the pantry
A database that stores your data as simple items looked up by a key (an `id`).
No server to run; AWS keeps it alive. You pay per read/write — fractions of a
cent.

## Why employers care

Putting "serverless" on a CV, backed by a real repo, signals that you
understand:
- **Managed services** — using cloud building blocks instead of running
  everything yourself.
- **Pay-per-use cost thinking** — matching spend to actual demand.
- **Event-driven design** — code that runs in response to events, not in a
  constant loop.

These are core DevOps/cloud judgement skills, not just syntax.

Next: [how Terraform works →](03-terraform-basics.md)
