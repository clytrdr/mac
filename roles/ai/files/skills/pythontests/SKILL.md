---
name: pythontests
description: Follow these guidelines when creating, modifying, or refactoring Python test code (pytest). Defines conventions for test structure, mocking patterns, IDE inspection workflow, and verification.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, mcp__pycharm__get_file_problems, mcp__pycharm__lint_files
---

# Python Test Code Generation & Refactoring

Always read the source code and existing tests before writing or modifying tests.

## Workflow

1. Read the source file under test and the existing test file.
2. Run the IDE inspections on the test file. Record the baseline problem list.
3. Write or refactor the tests.
4. Run the tests: `pytest tests/path/to/test_file.py`. AI agents must not pass `-n auto`
   (the sandbox blocks xdist workers and the run hangs).
5. Run the IDE inspections again. The problem count must not increase. Fix new problems in the same pass.
6. Report the result: test outcome and the problem count before and after.

## IDE Inspections

PyCharm catches problems that a manual read misses: unresolved references in mock paths, argument
mismatches, unused imports, and wrong types. Use the PyCharm MCP server.

- Use `mcp__pycharm__get_file_problems` for one file and `mcp__pycharm__lint_files` for multiple files.
- Pass `projectPath` (project root) and project-relative paths. Set `errorsOnly` to `false`.
- Fix the root cause. Do not silence warnings with `# noqa`, `# type: ignore`, or `noinspection`.
- If the IDE warning is wrong, keep the code and report the warning as a false positive.
- If the PyCharm MCP tools are not available, state this once and continue.

## Philosophy

- Verify meaningful behavior, not coverage numbers.
- Skip a test if it requires many stacked mocks. Such a test targets implementation details.
- Focus on tests that catch real bugs and document intended behavior.

## Test Organization

- Mirror the source code structure under `tests/`.
- Create one test class per function (`Test<FunctionName>`) or per class (`Test<ClassName>`).

## Database Tests (TortoiseORM)

Apply this section only in a project that uses TortoiseORM.

- Inherit from `tortoise.contrib.test.TestCase`. Use `asyncSetUp` and async test methods.
- Never mock database models.
- Call `tests.utils.init_test_data()` to load standard test data (Company, Market, OrderStatus).
  Use it as the baseline. Omit it when a minimal setup is clearer.

## Router Tests (FastAPI)

Apply this section only in a project that uses FastAPI.

- Create a minimal `FastAPI` app, include the router, and create `TestClient` at the module level.
- Use synchronous test methods. Assert on `response.status_code` and `response.json()`.
- Mock external dependencies with `@patch.object`.

## Mocking Strategy

### `@patch.object` first, string `@patch` second

Prefer `@patch.object` when mocking class methods. For imported module-level names
(such as client classes, helpers, or config objects), use `@patch` with a string literal:

```python
@patch("mypackage.clients.slack.WebClient")
```

Do not construct paths with f-strings (`@patch(f"{SlackClient.__module__}.WebClient")`).
PyCharm cannot resolve dynamic path fragments and reports `Unresolved reference` errors.
Do not use `@patch.object(module_object, "WebClient")`. PyCharm treats plain
`from x import Y` imports as private under PEP 484 re-export rules.

### Put `@patch` on the class, not on the method

Apply `@patch` decorators to the test class when a test method takes pytest fixtures
or `parametrize` arguments. PyCharm checks method-level `@patch` counts against method
parameters and reports extra-parameter errors. PyCharm skips this check for class-level decorators.

A class-level patch applies to every `test_*` method. Add the mock parameter to test methods
that do not use it and prefix its name with an underscore (`_mock_load`).

If tests in the same class need different return values, do not pass `return_value` to
the decorator. Set `mock_x.return_value = ...` inside the test function body.

### Assertions on mocks

Assert on the mock instance created by the test. Do not assert through attributes annotated
with real types. PyCharm resolves type annotations and reports `Cannot find reference` errors.

```python
# Good: mock_storage_cls is the patched class.
mock_storage_cls.return_value.upload_file.assert_called_once_with(...)

# Bad: _storage_client is annotated as StorageClient.
handler._storage_client.upload_file.assert_called_once_with(...)
```

To verify call arguments, unpack `call_args` and assert on individual fields instead of calling
`assert_called_with()`:

```python
_, kwargs = mock_request.call_args
assert kwargs["json"]["OrderType"] == "Limit"
```

### Async mocking

Use `AsyncMock` to mock async methods: `@patch.object(Cls, "method", new_callable=AsyncMock)`.

$ARGUMENTS
