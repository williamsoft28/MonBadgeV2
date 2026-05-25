// Seuil de distance euclidienne (plus c'est bas, plus c'est strict)
const SIMILARITY_THRESHOLD = 10.0; // Facenet L2 norm euclidien threshold par défaut

// Initialisation vide (plus besoin de charger les modèles locaux)
const initFaceApi = async () => {
  console.log('✅ Biométrie : Les modèles locaux sont désactivés (DeepFace Python utilisé).');
};

/**
 * Obtient le descripteur facial (vecteur à 128 dimensions)
 * via le microservice Python DeepFace.
 * @param {string} base64Image
 * @returns {Promise<Float32Array|null>}
 */
const getFaceDescriptor = async (base64Image) => {
  try {
    const response = await fetch('http://127.0.0.1:5000/represent', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ image: base64Image })
    });
    
    const data = await response.json();

    if (response.ok && data.success && data.embedding) {
      // Convertir l'array en Float32Array JavaScript
      return new Float32Array(data.embedding);
    } else {
      console.warn(`[DeepFace API] ${data.error || 'Erreur inconnue'}`);
      return null;
    }
  } catch (error) {
    console.error('[DeepFace API] Erreur de communication avec le serveur Python (Est-il démarré sur le port 5000 ?)', error.message);
    return null;
  }
};

/**
 * Calcule la distance euclidienne entre deux descripteurs.
 * (Utilisé par Facenet pour déterminer la similarité)
 */
const compareFaces = (descriptor1, descriptor2) => {
  if (!descriptor1 || !descriptor2 || descriptor1.length !== descriptor2.length) {
    return Number.MAX_VALUE;
  }

  // Calcul de la distance Cosinus (plus performant pour Facenet512)
  let dotProduct = 0.0;
  let norm1 = 0.0;
  let norm2 = 0.0;
  
  for (let i = 0; i < descriptor1.length; i++) {
    dotProduct += descriptor1[i] * descriptor2[i];
    norm1 += descriptor1[i] * descriptor1[i];
    norm2 += descriptor2[i] * descriptor2[i];
  }
  
  if (norm1 === 0 || norm2 === 0) return Number.MAX_VALUE;
  
  const cosineSimilarity = dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
  
  // Retourne la distance cosinus (0 = parfaitement identique, 1 = orthogonal)
  return Math.max(0, 1 - cosineSimilarity);
};

module.exports = {
  initFaceApi,
  getFaceDescriptor,
  compareFaces,
  SIMILARITY_THRESHOLD
};
