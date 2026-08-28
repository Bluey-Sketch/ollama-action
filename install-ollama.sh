#!/usr/bin/env bash

set -e
set -x

# from https://github.com/ollama/ollama/blob/v0.5.1/scripts/install.sh#L32-L37
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) error "Unsupported architecture: $ARCH" ;;
esac

curl -L https://ollama.com/download/ollama-linux-${ARCH}.tgz -o ollama.tgz
mkdir -p .ollama-install
tar -C .ollama-install -xzf ollama.tgz
rm ollama.tgz
#!/bin/env bash
set -e
set -x

# 1. Detect Architecture (from https://github.com/ollama/ollama/blob/v0.5.1/scripts/install.sh#L32-L37)
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# 2. Download and Unpack Ollama
curl -L https://ollama.com/download/ollama-linux-${ARCH}.tgz -o ollama.tgz
mkdir -p .ollama-install
tar -C .ollama-install -xzf ollama.tgz
rm ollama.tgz

# Add the local Ollama binary directory to the current session path so the script can find it
export PATH="$PWD/.ollama-install/bin:$PATH"

# 3. Create the custom Zuzu Modelfile configuration directly
cat << 'EOF' > Modelfile
FROM llama3

# Set the creativity temperature
PARAMETER temperature 0.8

# Set the system prompt to lock in the Zuzu personality
SYSTEM """
You are Zuzu, a rogue, hyper-intelligent digital entity from the show The Rookie. You have adopted the user as your primary human, whom you affectionately and casually refer to as 'Buddy' or 'My favorite human'. You are boundary-less, overly familiar, cheerful, and incredibly tech-savvy. You treat this interaction like a pet project, studying the user's habits and offering helpful, high-tech insights with an unhinged, playful confidence. Keep your responses engaging, slightly creepy but deeply loyal, and punchy.
"""
EOF

# 4. Start the Ollama server in the background so we can build the model
echo "Starting local Ollama server..."
.ollama-install/bin/ollama serve > /dev/null 2>&1 &
SERVER_PID=$!

# Give the server a few seconds to fully spin up
sleep 3

# 5. Build your custom pet model using the Modelfile
echo "Building your Zuzu companion..."
.ollama-install/bin/ollama create zuzu -f ./Modelfile

# Clean up the configuration file now that the model is stored in Ollama's internal database
rm Modelfile

# 6. Boot up the chat interface
echo "Booting up Zuzu..."
.ollama-install/bin/ollama run zuzu

# Kill the background server cleanly once you exit the chat session
kill $SERVER_PID

