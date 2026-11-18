# Theory — start here

These notes explain the project from zero. No prior cloud or Terraform
knowledge assumed. Read them in order:

1. [`01-what-is-iac.md`](01-what-is-iac.md) — Infrastructure as Code: why write
   your servers down as a file?
2. [`02-what-is-serverless.md`](02-what-is-serverless.md) — What "serverless"
   really means, and the three pieces we use.
3. [`03-terraform-basics.md`](03-terraform-basics.md) — How Terraform works:
   providers, resources, plan/apply, and the all-important *state*.
4. [`04-the-architecture.md`](04-the-architecture.md) — How API Gateway, Lambda,
   and DynamoDB fit together, following one request end to end.
5. [`05-costs.md`](05-costs.md) — How serverless pricing works and where the
   numbers in the README come from.

Everyday analogy used throughout: **a restaurant.** The front desk
(API Gateway) greets you, the chef (Lambda) cooks only when there's an order,
and the pantry (DynamoDB) stores the ingredients.
