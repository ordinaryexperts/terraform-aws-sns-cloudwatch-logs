"""Write log entries to cloudwatch logs."""

import logging
import os

import environs
import structlog
import watchtower
import datetime
import pytz

env = environs.Env()
log = structlog.stdlib.get_logger()


TIMESTAMP = datetime.datetime.now(pytz.utc)


def handler(event, context):
    # Debug logging
    log_level = env.log_level("log_level", logging.INFO)
    structlog.configure(wrapper_class=structlog.make_filtering_bound_logger(log_level))

    cwLogger = logging.getLogger("cloudwatch")
    cwLogger.setLevel(logging.INFO)
    cloudwatch_log_group = env.str("log_group")
    cloudwatch_log_stream = TIMESTAMP.strftime("%Y-%m-%d/%H-%M-%S")
    cloudwatch_handler = watchtower.CloudWatchLogHandler(
        log_group=cloudwatch_log_group, stream_name=cloudwatch_log_stream
    )
    cwLogger.addHandler(cloudwatch_handler)

    try:
        # FIXME: What if there are more than one record?
        message_source = event["Records"][0]["EventSource"]
    except KeyError:
        log.warn("Unexpected event format", lambda_event=event)
        return

    if message_source == "aws:sns":
        body = event["Records"][0]["Sns"]["Message"]
        cwLogger.info(body)
        cloudwatch_handler.flush()
    else:
        log.warn("Message source is not aws:sns", event=event)

    # FIXME: What should we return?
    return
