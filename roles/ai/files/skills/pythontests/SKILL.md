---
name: pythontests
description: Follow these guidelines when you write, modify, or refactor Python test code (pytest). Defines conventions for test structure, mocking patterns, and verification.
---

## Workflow

1. Read the source file under test and the existing test file, if one exists.
2. List the behaviors of the source file. Map each existing test to a behavior.
3. Add, simplify, rename, or remove tests. Apply all rules below to the existing tests in the file too.
4. Run the tests: `pytest tests/path/to/test_file.py`. Do not pass `-n auto`.
   The sandbox blocks xdist workers. The run hangs.
   If the project configuration adds `-n`, pass `-n 0`.
5. Report the test outcome.

Do not add suppression comments such as `# noqa` or `# type: ignore`. Fix the root cause.
Exception: use `# type: ignore` when a test passes a value of the wrong type on purpose.

## Test Selection

Fewer and simpler tests are better. Test behavior, not coverage numbers.

Keep or add a test only if a change to the source code can make this test fail while all other tests pass.
Otherwise, remove the test or do not add it. Common cases:
- Another test already runs the same path. Move the assertion into that test.
- The conditions are independent and already tested separately.

Also remove a test, or do not add it, in these cases:
- The test needs many stacked mocks. It tests implementation details.
- The test expects `AssertionError`. Assert statements document invariants and narrow types.
  They are not runtime behavior.

Keep each test simple:
- Use only the setup and mocks that the behavior needs.
- Do not put conditionals in a test body.
- Use a loop in a test body only to prepare test data. Do not assert inside a loop. Use `parametrize`.

## Test Organization

- Mirror the source code structure under `tests/`.
- Create one test class per function (`Test<FunctionName>`, such as `TestParseOrder` for `parse_order`)
  or per class (`Test<ClassName>`).
- Name each test `test_<condition>_<expected_result>` (for example, `test_empty_input_returns_none`).
  Rename tests with names like `test_1`, `test_success`, or `test_basic`.
- Add a docstring only for context that the name cannot hold, such as why a setup is needed or a related bug.
  Remove docstrings that only repeat the test name.

## Database Tests (TortoiseORM)

Apply this section only in a project that uses TortoiseORM and defines the `db` fixture in `tests/conftest.py`.

- Use the `db` fixture in `tests/conftest.py`. Add `@pytest.mark.usefixtures("db")` to the test class.
  Use async test methods.
- To load standard test data (Company, Market, and OrderStatus), use the `seed_data` fixture
  instead of `db`: `@pytest.mark.usefixtures("seed_data")`. `seed_data` depends on `db`.
  Use `db` alone when a minimal setup is clearer.
- For per-class setup, use an `autouse` fixture that takes `db` or `seed_data` as an argument:

  ```python
  @pytest.fixture(autouse=True)
  async def _setup(self, seed_data):
      self.diary_row = await _create_diary()
  ```

  Autouse fixtures run before the fixtures in `usefixtures`.
  If `_setup` does not take `db` or `seed_data`, it runs before the database exists.
  If `_setup` takes one of them, the class does not need `usefixtures`.
- Never mock database models.
  Exception: patch a model method to make a database error happen.

## Router Tests (FastAPI)

Apply this section only in a project that uses FastAPI.

- Create a minimal `FastAPI` app and include the router at the module level.
- Without database access, use `TestClient` and synchronous test methods.
- With database access, use `httpx.AsyncClient(transport=ASGITransport(app=app), base_url="http://testserver")`
  and async test methods.
- Assert on `response.status_code` and `response.json()`.

## Mocking

### Patch targets

- Use `@patch.object` for methods of a class.
- Use `new_callable=AsyncMock` for async methods: `@patch.object(Cls, "method", new_callable=AsyncMock)`.
- Use `@patch` with a string literal for imported module-level names, such as client classes, helpers, or config objects:

  ```python
  @patch("mypackage.clients.slack.WebClient")
  ```

- Do not build the path with an f-string (`@patch(f"{SlackClient.__module__}.WebClient")`).
  Do not use `@patch.object(module_object, "WebClient")`.
  A string literal shows the full patch target in one place. It is easy to read and to search.

### Assertions on mocks

Assert on the mock that the test created. Do not assert through attributes annotated with real types.
A type checker sees the real type. It reports that the assert method does not exist on that type.

```python
# Good: mock_storage_cls is the patched class.
mock_storage_cls.return_value.upload_file.assert_called_once_with(...)

# Bad: _storage_client is annotated as StorageClient.
handler._storage_client.upload_file.assert_called_once_with(...)
```

Use `assert_called_once_with(...)` only when the test checks every argument.
To check some of the arguments, unpack `call_args` and assert on single fields. Do not use `assert_called_with()`:

```python
_, kwargs = mock_request.call_args
assert kwargs["json"]["OrderType"] == "Limit"
```
