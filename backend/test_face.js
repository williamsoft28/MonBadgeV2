const faceService = require('./src/services/faceService');
const fs = require('fs');

async function test() {
  try {
    const base64Image = 'data:image/jpeg;base64,' + Buffer.from('test').toString('base64');
    console.log("Testing with dummy data...");
    const descriptor = await faceService.getFaceDescriptor(base64Image);
    console.log("Descriptor:", descriptor);
  } catch (err) {
    console.error("Error:", err);
  }
}

test();
