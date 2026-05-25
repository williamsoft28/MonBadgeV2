import os
import io
import base64
import numpy as np
import cv2
from flask import Flask, request, jsonify
from deepface import DeepFace

app = Flask(__name__)

# Modèle recommandé : Facenet512
MODEL_NAME = "Facenet512"
DETECTOR = "mtcnn" # MTCNN est BEAUCOUP plus performant que le détecteur par défaut (opencv)

@app.route('/represent', methods=['POST'])
def represent():
    try:
        data = request.json
        if not data or 'image' not in data:
            return jsonify({'error': 'No image provided'}), 400

        image_data = data['image']
        
        # Nettoyer l'en-tête base64
        if ',' in image_data:
            image_data = image_data.split(',')[1]

        # Convertir base64 en image OpenCV
        img_bytes = base64.b64decode(image_data)
        nparr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if img is None:
            return jsonify({'error': 'Invalid image format'}), 400

        # Sauvegarder l'image reçue pour vérifier ce que la caméra envoie réellement
        cv2.imwrite('debug_received_image.jpg', img)

        # Tentative d'extraction avec l'image originale
        objs = None
        try:
            objs = DeepFace.represent(img_path=img, model_name=MODEL_NAME, enforce_detection=True, detector_backend=DETECTOR)
        except ValueError:
            pass

        # Si DeepFace échoue, on teste les rotations
        if not objs:
            rotations = [cv2.ROTATE_90_CLOCKWISE, cv2.ROTATE_180, cv2.ROTATE_90_COUNTERCLOCKWISE]
            for rotation in rotations:
                rotated_img = cv2.rotate(img, rotation)
                try:
                    objs = DeepFace.represent(img_path=rotated_img, model_name=MODEL_NAME, enforce_detection=True, detector_backend=DETECTOR)
                    if objs and len(objs) > 0:
                        break
                except ValueError:
                    continue

        if not objs or len(objs) == 0:
            return jsonify({'error': 'Impossible de détecter un visage. Vérifiez debug_received_image.jpg'}), 400

        # On prend le premier visage trouvé
        embedding = objs[0]['embedding']

        return jsonify({
            'success': True,
            'embedding': embedding
        })

    except Exception as e:
        print("Erreur:", str(e))
        return jsonify({'error': 'Erreur interne du serveur', 'details': str(e)}), 500

if __name__ == '__main__':
    print(f"Démarrage du microservice biométrique DeepFace (Modèle: {MODEL_NAME})...")
    # Premier appel à vide pour charger le modèle en mémoire (évite le lag à la 1ère requête)
    try:
        dummy_img = np.zeros((224, 224, 3), dtype=np.uint8)
        DeepFace.represent(img_path=dummy_img, model_name=MODEL_NAME, enforce_detection=False)
        print("Modèle chargé en mémoire avec succès !")
    except Exception as e:
        print("Avertissement: le pré-chargement du modèle a échoué (sera chargé à la première requête).")

    # Lancement du serveur sur le port 5000
    app.run(host='127.0.0.1', port=5000, debug=False)
