"""
handler.py — the Lambda function (the "taxi driver").

One function handles every route. API Gateway sends an "event" describing the
HTTP request (method, path, body); we look at it, do the right thing against
DynamoDB, and return an HTTP response.

Routes:
    GET    /health         -> liveness check
    GET    /items          -> list all items
    POST   /items          -> create an item   (body: {"text": "..."})
    GET    /items/{id}     -> fetch one item
    DELETE /items/{id}     -> delete one item

No external libraries: boto3 (the AWS SDK) is already available inside the
Lambda runtime, so there is nothing to pip install.
"""

import json
import os
import uuid
from datetime import datetime, timezone

import boto3

# Create the DynamoDB client once, OUTSIDE the handler. Lambda reuses a warm
# function across calls, so this connection is set up once and reused — faster
# and cheaper than reconnecting every request.
TABLE_NAME = os.environ["TABLE_NAME"]
table = boto3.resource("dynamodb").Table(TABLE_NAME)


def _response(status: int, body: dict) -> dict:
    """Build the HTTP response shape API Gateway expects."""
    return {
        "statusCode": status,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(body),
    }


def handler(event, context):
    """Entry point. API Gateway (HTTP API v2) calls this for every request."""
    route = event.get("routeKey", "")          # e.g. "POST /items"
    path_params = event.get("pathParameters") or {}
    item_id = path_params.get("id")

    try:
        if route == "GET /health":
            return _response(200, {"status": "ok"})

        if route == "GET /items":
            result = table.scan()
            return _response(200, {"items": result.get("Items", [])})

        if route == "POST /items":
            body = json.loads(event.get("body") or "{}")
            text = (body.get("text") or "").strip()
            if not text:
                return _response(400, {"error": "field 'text' is required"})

            item = {
                "id": str(uuid.uuid4()),
                "text": text,
                "created_at": datetime.now(timezone.utc).isoformat(),
            }
            table.put_item(Item=item)
            return _response(201, item)

        if route == "GET /items/{id}":
            result = table.get_item(Key={"id": item_id})
            item = result.get("Item")
            if not item:
                return _response(404, {"error": "item not found"})
            return _response(200, item)

        if route == "DELETE /items/{id}":
            table.delete_item(Key={"id": item_id})
            return _response(204, {})

        return _response(404, {"error": f"no route for {route}"})

    except json.JSONDecodeError:
        return _response(400, {"error": "body must be valid JSON"})
    except Exception as exc:  # last-resort guard so we never leak a stack trace
        print(f"ERROR handling {route}: {exc}")  # goes to CloudWatch logs
        return _response(500, {"error": "internal server error"})
