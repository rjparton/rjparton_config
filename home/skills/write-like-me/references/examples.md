# Style patterns

These examples capture useful patterns from Robert's writing. They are references for voice and
explanation, not a mandatory document template.

## 1. Problem, evidence, decision

Pattern:

> We depend on X today. It fails in these concrete ways, costs this much, and creates this risk.
> We need Y to meet these named requirements. We intend to build, extend, or adopt Z.

The passage reaches the decision quickly, uses specific evidence, and commits once the support is
established.

Avoid:

> The evolving landscape presents a compelling opportunity to explore a holistic solution that
> could unlock value across a number of use cases.

## 2. Definition with a reason and example

Pattern:

> A workload is one unit of computation with a clear input and output. Grouping the work this way
> isolates failures and makes retries explicit. A daily report job is one example.

The definition names the thing, states its boundary, explains why it exists, and grounds it in an
example.

## 3. User workflow before internals

Pattern:

1. The developer submits a configuration through the CLI.
2. The service validates and stores the request.
3. A worker processes it and writes the result.
4. The developer reads that result through the SDK.

Only after this path is clear does the document unpack each component. The workflow gives every
internal detail a purpose.

## 4. Life of a request

Pattern:

1. Name the caller and exact entry point.
2. Follow validation and persisted state.
3. Follow the scheduler creating work.
4. Follow data reads, computation, and writes.
5. End at the result visible to the caller.

This is stronger than beginning with a catalogue of services because chronology explains how the
parts interact.

## 5. Small, explicit choices

Examples of the cadence:

> Results are immutable. We will not add versioning initially: they are cheap to recreate, and
> versioning can be added later without breaking the API.

> The worker is ephemeral because the work is bursty and bounded. Resources are released when it
> completes.

Each passage states the choice, gives the direct reason, and stops.

## 6. Boundaries through contrast

Pattern:

> Batch jobs produce historical reports. The online service answers current requests.

> The data path never crosses the control plane. Control-plane availability limits what we can
> change, not what we can serve.

Short contrasts make ownership and failure boundaries clear.

## 7. Numbers instead of adjectives

| Vague | Concrete |
| --- | --- |
| Highly available | 99.9% availability |
| Fast processing | 10M rows in 20 minutes |
| Low latency | 40ms p50, 90ms p95 |
| Enough capacity | 4x the weekly peak |

The number can be a target rather than a measurement, but the text must label it honestly.

## 8. Interfaces make behavior real

After explaining the workflow, show the smallest realistic interface that resolves ambiguity:

```python
result = await client.create_report(
    query=query,
    tags={"use_case": "weekly_review"},
)
```

Explain the consequential choices around the interface. Do not narrate every line.

## 9. Before and after

### Architecture first to user first

Before:

> The system consists of an API, scheduler, workers, and object storage.

After:

> A developer submits a request through the CLI. The API stores it, the scheduler creates a worker,
> and the worker writes the completed result to object storage.

### Abstract to concrete

Before:

> The platform should provide a scalable and reliable mechanism for offline access.

After:

> A developer supplies a query. The platform runs it, writes the resulting table, and returns a
> Python handle for analysis.

### Inflated to direct

Before:

> This approach enables the organization to leverage a unified paradigm while maintaining the
> flexibility required to accommodate diverse future requirements.

After:

> Batch and streaming inputs use the same definition. The source changes; the processing logic does
> not.
