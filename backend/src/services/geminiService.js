const apiKey = process.env.GEMINI_API_KEY;
const GEMINI_MODEL = 'gemini-3.1-flash-lite';
const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

if (!apiKey) {
  console.warn('GEMINI_API_KEY is missing from backend .env');
}

async function generatePlaceSummary({ placeName, category, accessibilityTags }) {
  if (!apiKey) {
    throw new Error('GEMINI_API_KEY is missing from backend .env');
  }

  const tagsText =
    Array.isArray(accessibilityTags) && accessibilityTags.length > 0
      ? accessibilityTags.join(', ')
      : 'No specific accessibility features available';

  const prompt = `
Act as an assistant specialized in urban accessibility.

Provide an accessibility summary for the place: "${placeName}".

Category: ${category}
Known accessibility features: ${tagsText}

Write in English only.

Keep the response friendly and concise, and organized into paragraphs (maximum 4 sentences).

Focus on the information that a wheelchair user or a visually impaired user would find useful before visiting the location.

If accessibility information is limited, clearly state what is known and recommend checking conditions on-site before visiting.
`;

  const response = await fetch(GEMINI_API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey,
    },
    body: JSON.stringify({
      contents: [
        {
          role: 'user',
          parts: [{ text: prompt }],
        },
      ],
    }),
  });

  const data = await response.json();

  if (!response.ok) {
    const errorMessage =
      data?.error?.message ||
      data?.error?.status ||
      `Gemini request failed with status ${response.status}`;

    throw new Error(errorMessage);
  }

  const text = data?.candidates?.[0]?.content?.parts
    ?.map((part) => part.text)
    .filter(Boolean)
    .join('\n')
    .trim();

  if (!text) {
    throw new Error('Gemini response did not include generated text');
  }

  return text;
}

module.exports = {
  generatePlaceSummary,
};