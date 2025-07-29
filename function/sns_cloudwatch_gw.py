"""Write log entries to cloudwatch logs."""

import logging
from typing import Any, Dict

import environs
import structlog
import watchtower
import datetime
import pytz

env = environs.Env()
log = structlog.stdlib.get_logger()


def handler(event: Dict[str, Any], context: Any) -> None:
    # Debug logging
    log_level = env.log_level("LOG_LEVEL", logging.INFO)
    structlog.configure(wrapper_class=structlog.make_filtering_bound_logger(log_level))

    cwLogger = logging.getLogger("cloudwatch")
    cwLogger.setLevel(logging.INFO)
    # Prevent propagation to root logger to avoid double logging
    cwLogger.propagate = False
    cloudwatch_log_group = env.str("LOG_GROUP")
    log_stream_format = env.str("LOG_STREAM_FORMAT", "%Y-%m-%d/%H00")
    now = datetime.datetime.now(pytz.utc)
    cloudwatch_log_stream = now.strftime(log_stream_format)
    cloudwatch_handler = watchtower.CloudWatchLogHandler(
        log_group=cloudwatch_log_group, stream_name=cloudwatch_log_stream
    )
    cwLogger.addHandler(cloudwatch_handler)

    # Process all records in the event
    if "Records" not in event:
        log.warn("Unexpected event format - missing Records", lambda_event=event)
        return

    for record in event["Records"]:
        # Skip records without EventSource
        if "EventSource" not in record:
            log.warn("Unexpected record format - missing EventSource", record=record)
            continue

        # Only process SNS records
        if record["EventSource"] != "aws:sns":
            log.warn("Skipping non-SNS record", event_source=record["EventSource"], record=record)
            continue

        # Extract and log the SNS message
        if "Sns" not in record or "Message" not in record.get("Sns", {}):
            log.warn("Unexpected SNS record format - missing Sns.Message", record=record)
            continue

        cwLogger.info(record["Sns"]["Message"])

    # Flush after processing all records
    cloudwatch_handler.flush()

    # Lambda doesn't require a specific return value for asynchronous invocations
    # Returning None indicates successful completion
    return


if __name__ == "__main__":
    handler({}, None)
