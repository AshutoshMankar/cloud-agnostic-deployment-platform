
import os
import time
import redis

REDIS_HOST = os.getenv("REDIS_HOST", "redis")
QUEUE_NAME = os.getenv("QUEUE_NAME", "jobs")
PROCESSING_QUEUE = f"{QUEUE_NAME}:processing"

client = redis.Redis(
    host=REDIS_HOST,
    port=6379,
    decode_responses=True,
    socket_connect_timeout=5,
    socket_timeout=10,
)

def recover_pending_jobs():
    recovered = 0
    while client.lmove(PROCESSING_QUEUE, QUEUE_NAME, "RIGHT", "LEFT"):
        recovered += 1
    if recovered:
        print(f"Recovered {recovered} unfinished jobs", flush=True)

print(
    f"Worker started; consuming '{QUEUE_NAME}' from {REDIS_HOST}:6379",
    flush=True,
)

while True:
    try:
        # Recover jobs left in the processing queue after a restart.
        recover_pending_jobs()

        # Atomically move a job into the processing queue.
        job_id = client.brpoplpush(
            QUEUE_NAME, PROCESSING_QUEUE, timeout=5
        )

        if job_id is None:
            continue

        try:
            # Placeholder business operation.
            print(f"Processed job: {job_id}", flush=True)

            # Acknowledge only after successful processing.
            client.lrem(PROCESSING_QUEUE, 1, job_id)

        except Exception as exc:
            print(f"Processing failed for {job_id}: {exc}", flush=True)
            # Leave the job in the processing queue for recovery.

    except redis.RedisError as exc:
        print(f"Redis error: {exc}", flush=True)
        time.sleep(2)
