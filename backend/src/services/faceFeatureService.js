/** Seuil de similarité (80 %) pour valider un visage */
const SIMILARITY_THRESHOLD = 0.8;

/**
 * Compare deux vecteurs de features ML Kit (landmarks normalisés + pose).
 * Retourne un score entre 0 et 1 (1 = identique).
 */
const compareFeatures = (savedFeatures, currentFeatures) => {
  if (
    !Array.isArray(savedFeatures) ||
    !Array.isArray(currentFeatures) ||
    savedFeatures.length === 0 ||
    savedFeatures.length !== currentFeatures.length
  ) {
    return 0;
  }

  let dot = 0;
  let normA = 0;
  let normB = 0;
  let sumSq = 0;

  for (let i = 0; i < savedFeatures.length; i++) {
    const a = Number(savedFeatures[i]);
    const b = Number(currentFeatures[i]);
    if (Number.isNaN(a) || Number.isNaN(b)) continue;
    dot += a * b;
    normA += a * a;
    normB += b * b;
    const d = a - b;
    sumSq += d * d;
  }

  const cosine =
    normA > 0 && normB > 0 ? dot / (Math.sqrt(normA) * Math.sqrt(normB)) : 0;
  const distance = Math.sqrt(sumSq);
  const euclideanSim = Math.max(0, 1 - distance / 1.5);

  // Combinaison cosine + distance euclidienne
  const similarity = Math.max(0, Math.min(1, cosine * 0.4 + euclideanSim * 0.6));
  return similarity;
};

const isMatch = (similarity) => similarity >= SIMILARITY_THRESHOLD;

const toPercent = (similarity) => Math.round(similarity * 100);

module.exports = {
  SIMILARITY_THRESHOLD,
  compareFeatures,
  isMatch,
  toPercent,
};
