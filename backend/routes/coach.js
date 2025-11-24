const express = require('express');
const { v4: uuidv4 } = require('uuid');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth_mw');
const { chatCompletion } = require('../services/llm_client');
const {
  INDIA_CULTURE_GUARDRAILS,
  languageDirective,
  isHindiLanguage,
  normalizeHistory,
  buildUserContext,
} = require('../services/ai_prompt_utils');
const { fetchUserProfile } = require('../services/user_profile_service');
const db = require('../db/database');

const MAX_HISTORY_TURNS = 8;

router.post('/ask', authMiddleware, async (req, res) => {
  const userId = req.user.sub;
  const { question, history = [], language } = req.body || {};

  if (!question || typeof question !== 'string' || !question.trim()) {
    return res.status(400).json({ error: 'Question is required' });
  }

  try {
    const profile = fetchUserProfile(userId);
    const resolvedLanguage = (language || profile?.language || 'english').toString();
    const directive = languageDirective(resolvedLanguage);
    const normalizedHistory = normalizeHistory(history).slice(-MAX_HISTORY_TURNS);

    const context = {
      timestamp: new Date().toISOString(),
      user: buildUserContext(profile),
      question: question.trim(),
    };

    const messages = [
      {
        role: 'system',
        content: [
          'You are NutriCoach, a culturally aware Indian diet and lifestyle guide.',
          directive,
          'Keep replies under 120 words, include one clear action item, and root examples in everyday Indian homes.',
          INDIA_CULTURE_GUARDRAILS,
        ].join('\n'),
      },
      { role: 'user', content: `Context JSON:\n${JSON.stringify(context)}` },
      ...normalizedHistory,
      { role: 'user', content: question.trim() },
    ];

    let answerText = null;
    try {
      answerText = await chatCompletion({ messages, temperature: 0.8, maxTokens: 360 });
    } catch (err) {
      console.error('[Coach] LLM failure:', err.message || err);
    }

    const fallback = isHindiLanguage(resolvedLanguage)
      ? 'मैं सोचकर तुरंत जवाब देता हूँ, कृपया थोड़ा इंतज़ार करें।'
      : 'I need a moment to think that through. Please try again shortly.';
    const finalAnswer = (answerText || '').trim() || fallback;

    const entryId = uuidv4();
    try {
      db.prepare(
        `INSERT INTO coach_conversation_history
          (id, user_id, question, answer, language, metadata, created_at)
          VALUES (?, ?, ?, ?, ?, ?, ?)`
      ).run(
        entryId,
        userId,
        question.trim(),
        finalAnswer,
        resolvedLanguage,
        JSON.stringify({ historyCount: normalizedHistory.length }),
        Date.now()
      );
    } catch (err) {
      console.error('[Coach] Failed to persist conversation:', err.message || err);
    }

    res.json({ answer: finalAnswer, language: resolvedLanguage, entryId });
  } catch (err) {
    console.error('[Coach] Unexpected error:', err);
    const fallback = isHindiLanguage(language)
      ? 'मैं अभी जवाब देने में सक्षम नहीं हूँ। कृपया थोड़ी देर में पूछें।'
      : 'I ran into an issue answering that. Please ask again in a moment.';
    res.status(200).json({ answer: fallback, error: 'coach_unavailable' });
  }
});

router.get('/history', authMiddleware, (req, res) => {
  const userId = req.user.sub;
  const limit = Math.min(parseInt(req.query.limit, 10) || 10, 25);

  try {
    const rows = db
      .prepare(
        `SELECT id, question, answer, language, created_at
         FROM coach_conversation_history
         WHERE user_id = ?
         ORDER BY created_at DESC
         LIMIT ?`
      )
      .all(userId, limit);

    res.json({ history: rows });
  } catch (err) {
    console.error('[Coach] History fetch error:', err);
    res.status(500).json({ error: 'Unable to fetch coach history' });
  }
});

module.exports = router;
