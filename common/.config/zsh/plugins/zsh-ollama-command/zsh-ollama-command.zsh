ollama-command-suggestions() {
  local query=$BUFFER
  if [[ -z "$query" ]]; then return; fi

  zle -R "✦ Thinking... (qwen2.5-coder:1.5b)"

  # Use jq to safely construct the JSON payload. This prevents JSON syntax 
  # errors if the user's query contains double quotes (").
  local json_payload=$(jq -n \
    --arg model "${ZSH_OLLAMA_MODEL:-qwen2.5-coder:1.5b}" \
    --arg system "You are an expert Unix shell assistant. Output EXACTLY 5 distinct shell command variations to solve the user's request.
RULES:
1. Output ONLY valid, raw shell commands, one per line.
2. NO explanations, NO conversational text, NO warnings.
3. NO markdown formatting, NO code blocks, NO backticks.
4. NO numbered lists or bullet points (do not start lines with 1., 2., etc.).
5. Prioritize standard Unix utilities (e.g., find, grep, awk, sed, xargs, tar).
6. Default to the current directory (.) if no path is given." \
    --arg prompt "Task: $query\n\nRaw commands (one per line):" \
    '{
      model: $model,
      system: $system,
      prompt: $prompt,
      stream: false,
      options: { temperature: 0.1, num_predict: 150 }
    }')

  local raw_response=$(curl -s -X POST "${ZSH_OLLAMA_URL:-http://localhost:11434}/api/generate" \
    -d "$json_payload" -H "Content-Type: application/json" | jq -r '.response' 2>/dev/null)

  # Clean the output (kept your filters, but the stricter prompt should require them less)
  local clean_output=$(echo "$raw_response" | 
    sed "s/\`//g" | 
    sed 's/ (.*$//' | 
    sed 's/^[0-9][.)] //g' | 
    grep -v '^[[:space:]]*$' | 
    grep -ivE '(here|sure|you|can|following|note|null|actual)' |
    awk 'length($0) > 3 && (/[/-]/ || /\|/ || /\./ || / /)')

  zle reset-prompt

  if [[ -z "$clean_output" ]]; then
    clean_output="grep -r \"$query\" ."
  fi

  local selected_command=$(echo "$clean_output" | fzf \
    --height 10 \
    --reverse \
    --border \
    --header "💡 Suggestions for: $query")

  if [[ -n "$selected_command" ]]; then
    BUFFER="$selected_command"
    CURSOR=$#BUFFER
  fi
  zle reset-prompt
}

zle -N ollama-command-suggestions
bindkey "${ZSH_OLLAMA_COMMANDS_HOTKEY:-^g}" ollama-command-suggestions
