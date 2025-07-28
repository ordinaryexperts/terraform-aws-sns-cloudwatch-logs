"""Write log entries to cloudwatch logs."""

import logging

import environs
import structlog
import watchtower
import datetime
import pytz

env = environs.Env()
log = structlog.stdlib.get_logger()


def handler(event, context):
    # Debug logging
    log_level = env.log_level("LOG_LEVEL", logging.INFO)
    structlog.configure(wrapper_class=structlog.make_filtering_bound_logger(log_level))

    cwLogger = logging.getLogger("cloudwatch")
    cwLogger.setLevel(logging.INFO)
    cloudwatch_log_group = env.str("LOG_GROUP")
    now = datetime.datetime.now(pytz.utc)
    cloudwatch_log_stream = now.strftime("%Y-%m-%d/%H-%M")
    cloudwatch_handler = watchtower.CloudWatchLogHandler(
        log_group=cloudwatch_log_group, stream_name=cloudwatch_log_stream
    )
    cwLogger.addHandler(cloudwatch_handler)

    # Process all records in the event
    if "Records" not in event:
        log.warn("Unexpected event format - missing Records", lambda_event=event)
        return

    for record in event["Records"]:
        try:
            message_source = record["EventSource"]
        except KeyError:
            log.warn("Unexpected record format - missing EventSource", record=record)
            continue

        if message_source == "aws:sns":
            try:
                body = record["Sns"]["Message"]
                cwLogger.info(body)
            except KeyError:
                log.warn("Unexpected SNS record format - missing Sns.Message", record=record)
                continue
        else:
            log.warn("Message source is not aws:sns", record=record)

    # Flush after processing all records
    cloudwatch_handler.flush()

    # Lambda doesn't require a specific return value for asynchronous invocations
    # Returning None indicates successful completion
    return


if __name__ == "__main__":
    handler({}, None)
