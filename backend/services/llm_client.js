const nf = require('node-fetch');
const fetch = nf.default || nf;

const BASE_URL = process.env.GROQ_API_BASE || 'https://api.groq.com/openai/v1';
const API_KEY = process.env.GROQ_API_KEY || process.env.OPENAI_API_KEY || '';
const MODEL = process.env.GROQ_CHAT_MODEL || process.env.OPENAI_CHAT_MODEL || 'llama3-70b-8192';

async function chatCompletion({ messages, temperature = 0.8, maxTokens = 400, responseFormat }) {
  if (!API_KEY) {
    throw new Error('Missing GROQ_API_KEY or OPENAI_API_KEY for coach chat.');
  }

  const body = {
    model: MODEL,
    messages,
    temperature,
    top_p: 1,
    stream: false,
    max_completion_tokens: maxTokens,
  };

  if (responseFormat === 'json_object') {
    body.response_format = { type: 'json_object' };
  }

  const response = await fetch(`${BASE_URL}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${API_KEY}`,
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`LLM request failed (${response.status}): ${errorText}`);
  }

  const payload = await response.json();
  const choice = payload?.choices?.[0]?.message?.content;

  if (!choice) {
    return null;
  }

  if (Array.isArray(choice)) {
    return choice
      .map((part) => {
        if (typeof part === 'string') return part;
        if (part && typeof part === 'object' && part.text) return part.text;
        return '';
      })
      .join('')
      .trim();
  }

  return choice.toString().trim();
}

module.exports = { chatCompletion };
