# 5. How serverless pricing works

The single most important cost idea in this project:

> **You pay per request, not per hour.** An idle serverless app costs ~$0.

A traditional always-on server (EC2) bills by the hour whether it serves 0
requests or 1,000,000. Serverless flips that: no traffic, no bill.

## Where each cost comes from

### API Gateway (HTTP API)
Billed **per request**: about **$1.00 per million** requests in `eu-west-1`.
100,000 requests ≈ $0.10. First 12 months include 1,000,000 free/month.

### Lambda
Billed on **two things**: number of requests ($0.20 per million) and compute
time (memory × milliseconds). At our 128 MB and a few ms per call, compute is a
rounding error. The always-free tier (1M requests + 400,000 GB-seconds per
month) covers a portfolio project entirely.

### DynamoDB (on-demand)
Billed **per read and write**: roughly **$1.25 per million writes** and **$0.25
per million reads** on-demand. Plus storage, but 25 GB is always free. Our data
is tiny.

### CloudWatch Logs
Billed per GB **ingested** (~$0.50/GB) and stored. We cap retention at 14 days
and log very little, so this stays in the free 5 GB/month.

## The free tier covers this project

For normal portfolio traffic, **every service stays inside the AWS Free Tier,
so the realistic bill is $0.00/month.**

## If it grew to 100,000 requests/month

| Service      | Estimate |
|--------------|----------|
| API Gateway  | ~$0.10 |
| Lambda       | < $0.05 |
| DynamoDB     | < $0.13 |
| CloudWatch   | < $0.05 |
| **Total**    | **≈ $0.30 / month** |

Compare: a small always-on EC2 server for the same API would be **~$8–15/month
even while idle**. That contrast — *cost that scales to zero* — is the headline
to say out loud in an interview.

## Always verify
Cloud prices change and vary by region. Confirm current numbers with the
official sources:
- [AWS Pricing Calculator](https://calculator.aws/)
- [Lambda pricing](https://aws.amazon.com/lambda/pricing/)
- [API Gateway pricing](https://aws.amazon.com/api-gateway/pricing/)
- [DynamoDB pricing](https://aws.amazon.com/dynamodb/pricing/on-demand/)

## Safety habit
Set an **AWS Budgets** alert (e.g. email me if spend exceeds $1) the day you
create the account. It's free, and it means a surprise can never grow quietly.
