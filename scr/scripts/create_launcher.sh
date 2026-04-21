#!/bin/bash
# create_launcher.sh - Create Jarvis launcher scripts

set -e

echo "=============================================="
echo "  JARVIS INSTALLATION - LAUNCHER CREATION"
echo "=============================================="

LAUNCHER_DIR="$HOME/.jassir/bin"
mkdir -p "$LAUNCHER_DIR"

# Shell launcher
cat > "$LAUNCHER_DIR/jassir.sh" << 'SHELL_EOF'
#!/bin/bash
# Jarvis Launcher - Shell Interface

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
VENV="$SCRIPT_DIR/../venv"

# Activate environment
if [ -s "$VENV/bin/activate" ]; then
    source "$VENV/bin/activate"
fi

# Run Jarvis
exec python "$SCRIPT_DIR/jassir.py" "$@"
SHELL_EOF

# Python launcher
cat > "$LAUNCHER_DIR/jassir.py" << 'PYTHON_EOF'
#!/usr/bin/env python3
"""
Jarvis Launcher - Main Entry Point
"""
import sys
import os
import argparse
import json

# Add app directory to path
APP_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), 'app')
sys.path.insert(0, APP_DIR)

from jassir_core import jassir

def main():
    parser = argparse.ArgumentParser(
        description="JARVIS - Jarvis Desktop Assistant",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  jassir.py                      # Run with default model
  jassir.py --model model.gguf   # Use custom model
  jassir.py --web                # Start web interface
  jassir.py --benchmark          # Run performance test
        """
    )
    
    parser.add_argument(
        '--model', '-m',
        type=str,
        default=None,
        help='Path to model file'
    )
    parser.add_argument(
        '--web', '-w',
        action='store_true',
        help='Start web interface'
    )
    parser.add_argument(
        '--benchmark', '-b',
        action='store_true',
        help='Run performance benchmark'
    )
    parser.add_argument(
        '--config', '-c',
        type=str,
        default=None,
        help='Path to config file'
    )
    parser.add_argument(
        '--console', '-t',
        action='store_true',
        help='Start text console interface (default is voice)'
    )
    parser.add_argument(
        '--obsidian', '-o',
        type=str,
        default="~/Documents/Obsidian",
        help='Path to Obsidian vault for Knowledge Base'
    )
    
    args = parser.parse_args()
    
    if args.benchmark:
        run_benchmark()
    elif args.web:
        run_web_interface()
    elif args.console:
        run_console(args)
    else:
        # Default: voice-operated mode
        run_voice_interface(args)
    
    return 0

def run_console(args):
    """Run console interface"""
    # Initialize with optional model override
    if args.model:
        jassir.initialize_llm(args.model)
    if args.obsidian:
        jassir.initialize_knowledge_base(args.obsidian)
    
    # Run main application
    import jassir_app as app
    app.run()

def run_voice_interface(args):
    """Start voice interface"""
    if args.model:
        jassir.initialize_llm(args.model)
    if args.obsidian:
        jassir.initialize_knowledge_base(args.obsidian)
        
    from voice_interface import VoiceInterface
    vi = VoiceInterface()
    vi.run()

def run_web_interface():
    """Start web interface"""
    import subprocess
    import os
    
    web_app_path = os.path.join(APP_DIR, 'web_interface.py')
    print(f"Starting web interface: streamlit run {web_app_path}")
    
    # Run streamlit via the current python executable to ensure it uses the venv
    subprocess.run([sys.executable, "-m", "streamlit", "run", web_app_path])

def run_benchmark():
    """Run performance benchmark"""
    print("\n" + "="*60)
    print("  JARVIS PERFORMANCE BENCHMARK")
    print("="*60)
    
    import time
    
    # Warm up
    print("\n[1/5] Warming up...")
    jassir.query("Hello, test query for warmup.")
    
    # Run benchmarks
    print("[2/5] Running 10 query benchmarks...")
    queries = [
        "Explain quantum entanglement in simple terms",
        "Write a Python script to sort a list",
        "Analyze the following text: 'The quick brown fox jumps over the lazy dog'",
        "What are the implications of artificial intelligence on society?",
        "Create a SQL query to find duplicate records"
    ]
    
    times = []
    for i, query in enumerate(queries, 1):
        start = time.perf_counter()
        response = jassir.query(query)
        elapsed = (time.perf_counter() - start) * 1000  # ms
        
        times.append(elapsed)
        print(f"  Query {i}: {elapsed:.1f}ms")
    
    # Results
    print("\n[4/5] Results:")
    print(f"  Average latency: {sum(times)/len(times):.1f}ms")
    print(f"  Min latency: {min(times):.1f}ms")
    print(f"  Max latency: {max(times):.1f}ms")
    print(f"  Tokens/sec: {1000 / (sum(times)/len(times)):.1f}")
    
    print("\n[5/5] System Status:")
    status = jassir.get_system_status()
    print(json.dumps(status, indent=2))

if __name__ == "__main__":
    sys.exit(main())
PYTHON_EOF

# Make executable
chmod +x "$LAUNCHER_DIR/jassir.sh"
chmod +x "$LAUNCHER_DIR/jassir.py"

# Create symlink in PATH (optional)
if [ ! -d "$HOME/bin" ]; then
    mkdir -p "$HOME/bin"
fi
ln -sf "$LAUNCHER_DIR/jassir.sh" "$HOME/bin/jassir"

echo "✓ Launchers created at: $LAUNCHER_DIR"
echo "✓ Symlink created: $HOME/bin/jassir"
