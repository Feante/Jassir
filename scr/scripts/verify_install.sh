#!/bin/bash
# verify_install.sh - Complete installation verification

set -e

echo "=============================================="
echo "  JARVIS INSTALLATION - VERIFICATION"
echo "=============================================="

PASS=0
FAIL=0

# Test 1: Check Python environment
echo -n "Test 1: Python environment... "
if [ -d "$HOME/.jassir/venv/bin" ] && [ -f "$HOME/.jassir/venv/bin/python" ]; then
    echo "✓ PASS"
    ((PASS++))
else
    echo "✗ FAIL"
    ((FAIL++))
fi

# Test 2: Check llama.cpp
echo -n "Test 2: llama.cpp binary... "
if [ -f "$HOME/.jassir/llama/bin/llama-cli" ] && [ -x "$HOME/.jassir/llama/bin/llama-cli" ]; then
    echo "✓ PASS"
    ((PASS++))
else
    echo "✗ FAIL"
    ((FAIL++))
fi

# Test 3: Check model files
echo -n "Test 3: Model files... "
if [ -f "$HOME/.jassir/models/llama-2-13b-chat.Q8_0.gguf" ]; then
    echo "✓ PASS ($(ls -lh "$HOME/.jassir/models/llama-2-13b-chat.Q8_0.gguf" | awk '{print $5})"
    ((PASS++))
else
    echo "✗ FAIL"
    ((FAIL++))
fi

# Test 4: Check application code
echo -n "Test 4: Application code... "
if [ -f "$HOME/.jassir/app/jassir.py" ] && [ -f "$HOME/.jassir/app/jassir_core.py" ]; then
    echo "✓ PASS"
    ((PASS++))
else
    echo "✗ FAIL"
    ((FAIL++))
fi

# Test 5: Check launcher
echo -n "Test 5: Launcher script... "
if [ -x "$HOME/.jassir/bin/jassir.py" ]; then
    echo "✓ PASS"
    ((PASS++))
else
    echo "✗ FAIL"
    ((FAIL++))
fi

# Test 6: Hardware detection
echo -n "Test 6: ROCm detection... "
if command -v rocm-smi &> /dev/null; then
    GPU=$(rocm-smi | grep 'Name:' | head -1 | awk '{print $2}')
    echo "✓ PASS (GPU: $GPU)"
    ((PASS++))
else
    echo "⚠ WARNING (ROCm not detected)"
    ((FAIL++))
fi

# Test 7: Quick LLM test
echo -n "Test 7: LLM initialization... "
source "$HOME/.jassir/venv/bin/activate"
if python -c "
import sys
sys.path.insert(0, '$HOME/.jassir/app')
from jassir_core import jassir
success = jassir.initialize_llm()
sys.exit(0 if success else 1)
" 2>&1 | grep -q "LLM initialized"; then
    echo "✓ PASS"
    ((PASS++))
else
    echo "✗ FAIL"
    ((FAIL++))
fi

# Summary
echo ""
echo "=============================================="
echo "  VERIFICATION SUMMARY"
echo "=============================================="
echo "  Passed: $PASS"
echo "  Failed: $FAIL"

if [ $FAIL -eq 0 ]; then
    echo "  Status: ✓ ALL TESTS PASSED"
    exit 0
else
    echo "  Status: ✗ SOME TESTS FAILED"
    exit 1
fi

