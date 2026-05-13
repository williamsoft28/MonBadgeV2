const faceapi = require('@vladmandic/face-api');
const { Canvas, Image, ImageData, loadImage } = require('canvas');

faceapi.env.monkeyPatch({ Canvas, Image, ImageData });

async function test() {
  try {
    const base64Data = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";
    const buffer = Buffer.from(base64Data, 'base64');
    console.log("Loading image...");
    const img = await loadImage(buffer);
    console.log("Image loaded:", img.width, img.height);
  } catch (err) {
    console.error("Error:", err);
  }
}

test();
