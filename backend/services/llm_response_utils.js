function stripCodeFences(text) {
  if (!text) return '';
  let cleaned = text.trim();
  if (cleaned.startsWith('```')) {
    cleaned = cleaned.replace(/^```[a-zA-Z0-9_]*\s*/m, '');
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.slice(0, cleaned.lastIndexOf('```'));
    }
  }
  return cleaned.trim();
}

function attemptJsonParse(raw) {
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch (err) {
    const firstBrace = raw.indexOf('{');
    const lastBrace = raw.lastIndexOf('}');
    if (firstBrace !== -1 && lastBrace !== -1 && lastBrace > firstBrace) {
      try {
        return JSON.parse(raw.slice(firstBrace, lastBrace + 1));
      } catch (innerErr) {
        return null;
      }
    }
    return null;
  }
}

function parseJsonResponse(rawText) {
  if (!rawText) return null;
  const stripped = stripCodeFences(rawText);
  return attemptJsonParse(stripped);
}

module.exports = { parseJsonResponse };
