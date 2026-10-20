---
name: pythontests
description: Follow these guidelines when you write, modify, or refactor Python test code (pytest). Defines conventions for test structure, mocking patterns, IDE inspection workflows, and verification.
---

# Python Test Code Generation and Refactoring

## Workflow

1. Read the source file under test and the existing test file.
2. Run the IDE inspections on the test file. Record the problem count.
3. List the behaviors of the source file. Map each existing test to a behavior.
4. Add, simplify, rename, or remove tests. Apply all rules below to the existing tests in the file too.
5. Run the tests: `pytest tests/path/to/test_file.py`. Do not pass `-n auto`.
   The sandbox blocks xdist workers. The run hangs.
6. Run the IDE inspections again. The problem count must not increase.
7. Report the test outcome and the problem count before and after.

## IDE Inspections

- Use the PyCharm MCP tool `get_file_problems` for one file and `lint_files` for multiple files.
  The host environment may add a namespace to these tool names.
- Pass `projectPath` (project root) and project-relative paths. Set `errorsOnly` to `false`.
- Fix the root cause. Do not use `# noqa`, `# type: ignore`, or `noinspection`.
- If a warning is wrong, keep the code and report the warning as a false positive.
- If the PyCharm MCP tools are not available, state this once and continue.

## Test Selection

Fewer and simpler tests are better. Test behavior, not coverage numbers.

Keep or add a test only if some change to the source code makes only this test fail.
Otherwise, remove the test or do not add it. Common cases:
- Another test already runs the same path. Move the assertion into that test.
- The conditions are independent and already tested separately.
- The branch returns the same result as the default path.
- The test needs many stacked mocks. It tests implementation details.
- The test expects `AssertionError`. Assert statements document invariants and narrow types.
  They are not runtime behavior.

Keep each test simple:
- Use only the setup and mocks that the behavior needs.
- Do not put loops or conditionals in a test body.

## Test Organization

- Mirror the source code structure under `tests/`.
- Create one test class per function (`Test<FunctionName>`) or per class (`Test<ClassName>`).
- Name each test `test_<condition>_<expected_result>` (for example, `test_empty_input_returns_none`).
  Rename tests with names like `test_1`, `test_success`, or `test_basic`.
- Add a docstring only for context that the name cannot hold, such as why a setup is needed or a related bug.
  Remove docstrings that only repeat the test name.

## Database Tests (TortoiseORM)

Apply this section only in a project that uses TortoiseORM.

- Inherit from `tortoise.contrib.test.TestCase`. Use `asyncSetUp` and async test methods.
- Never mock database models.
- Call `tests.utils.init_test_data()` to load standard test data (Company, Market, and OrderStatus).
  Omit it when a minimal setup is clearer.

## Router Tests (FastAPI)

Apply this section only in a project that uses FastAPI.

- Create a minimal `FastAPI` app. Include the router and create a `TestClient` instance at the module level.
- Use synchronous test methods. Assert on `response.status_code` and `response.json()`.

## Mocking

### Patch targets

- Use `@patch.object` for class methods.
- Use `new_callable=AsyncMock` for async methods: `@patch.object(Cls, "method", new_callable=AsyncMock)`.
- Use `@patch` with a string literal for imported module-level names, such as client classes, helpers, or config objects:

  ```python
  @patch("mypackage.clients.slack.WebClient")
  ```

- Do not build the path with an f-string (`@patch(f"{SlackClient.__module__}.WebClient")`).
  PyCharm cannot resolve it. It reports `Unresolved reference` errors.
- Do not use `@patch.object(module_object, "WebClient")`.
  PyCharm treats plain `from x import Y` imports as private under PEP 484 re-export rules.

### Class-level patches

Put `@patch` on the test class when a test method takes pytest fixtures or `parametrize` arguments.
PyCharm checks method-level `@patch` counts against method parameters. It reports extra-parameter errors.
It skips this check for class-level decorators.

- A class-level patch applies to every `test_*` method. If a method does not use the mock,
  still add the parameter and prefix its name with an underscore (`_mock_load`).
- If tests need different return values, set `mock_x.return_value = ...` in the test body.
  Do not pass `return_value` to the decorator.

### Assertions on mocks

Assert on the mock that the test created. Do not assert through attributes annotated with real types.
PyCharm resolves the annotation and reports `Cannot find reference` errors.

```python
# Good: mock_storage_cls is the patched class.
mock_storage_cls.return_value.upload_file.assert_called_once_with(...)

# Bad: _storage_client is annotated as StorageClient.
handler._storage_client.upload_file.assert_called_once_with(...)
```

To check call arguments, unpack `call_args` and assert on single fields. Do not use `assert_called_with()`:

```python
_, kwargs = mock_request.call_args
assert kwargs["json"]["OrderType"] == "Limit"
```
