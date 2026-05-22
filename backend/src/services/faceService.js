const faceapi = require('@vladmandic/face-api');
const { Canvas, Image, ImageData, loadImage } = require('canvas');
const path = require('path');

// Configure face-api to use node-canvas
faceapi.env.monkeyPatch({ Canvas, Image, ImageData });

let modelsLoaded = false;

const loadModels = async () => {
  if (modelsLoaded) return;
  const modelsPath = path.join(__dirname, '../../models');
  try {
    await faceapi.nets.ssdMobilenetv1.loadFromDisk(modelsPath);
    await faceapi.nets.faceLandmark68Net.loadFromDisk(modelsPath);
    await faceapi.nets.faceRecognitionNet.loadFromDisk(modelsPath);
    modelsLoaded = true;
    console.log('✅ Modèles Face-API chargés avec succès');
  } catch (err) {
    console.error('❌ Erreur lors du chargement des modèles Face-API:', err);
  }
};

const getFaceDescriptor = async (base64Image) => {
  await loadModels();
  
  // Clean base64 string
  const base64Data = base64Image.replace(/^data:image\/\w+;base64,/, "");
  const buffer = Buffer.from(base64Data, 'base64');
  
  try {
    const img = await loadImage(buffer);
    
    // Detect single face and get descriptor
    const detection = await faceapi.detectSingleFace(img).withFaceLandmarks().withFaceDescriptor();
    if (!detection) {
      return null;
    }
    
    return detection.descriptor;
  } catch (err) {
    console.error('Face descriptor error:', err);
    return null;
  }
};

const compareFaces = (descriptor1, descriptor2) => {
  if (!descriptor1 || !descriptor2 || descriptor1.length !== descriptor2.length) {
    return NaN;
  }
  let dist = 0;
  for (let i = 0; i < descriptor1.length; i++) {
    dist += Math.pow(descriptor1[i] - descriptor2[i], 2);
  }
  return Math.sqrt(dist);
};

module.exports = {
  loadModels,
  getFaceDescriptor,
  compareFaces
};
