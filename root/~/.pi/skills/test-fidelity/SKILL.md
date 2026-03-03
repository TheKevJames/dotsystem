---
name: test-fidelity
description: Ensure test cases match production behaviour with high fidelity mocks. Use when touching test code.
---

# Test Fidelity

- Rule: if tests fail due to unrealistic mocks, first improve mocks/fixtures before relaxing production contracts
- Fix root cause, don't just suppress warnings or errors
- Default policy: prioritize true fixes over warning filters/ignores
- If suppression of warnings or errors is considered, explicitly ask first
- Ask before changing public behaviour for test convenience
- Include print statements in tests where those statements would be useful for debugging why a test failed
- Align mocks to match real object interfaces
