#!/usr/bin/env python3
"""
Servidor webhook simple que recibe POST requests y envía emails via SMTP Mailtrap
"""
from flask import Flask, request, jsonify
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# ============================================
# CONFIGURACIÓN SMTP DE MAILTRAP
# ============================================
SMTP_HOST = "sandbox.smtp.mailtrap.io"
SMTP_PORT = 587
SMTP_USERNAME = "7c549514d5e656"
SMTP_PASSWORD = "7cf0c95869f155"
FROM_EMAIL = "fernando.apralize.tests@gmail.com"

def send_email(nombre, email, fecha, estado):
    """Envía email usando SMTP de Mailtrap"""
    try:
        # Crear mensaje
        message = MIMEMultipart()
        message["From"] = FROM_EMAIL
        message["To"] = email
        message["Subject"] = "Reservación de Cita"
        
        # Cuerpo del email
        body = f'{nombre} el estado de su cita se actualiza como "{estado}" para {fecha} en su centro de atención.'
        message.attach(MIMEText(body, "plain"))
        
        # Conectar y enviar
        logger.info(f"Conectando a {SMTP_HOST}:{SMTP_PORT}...")
        server = smtplib.SMTP(SMTP_HOST, SMTP_PORT)
        server.starttls()
        
        logger.info(f"Autenticando con usuario {SMTP_USERNAME}...")
        server.login(SMTP_USERNAME, SMTP_PASSWORD)
        
        logger.info(f"Enviando email a {email}...")
        server.send_message(message)
        server.quit()
        
        logger.info(f"✅ Email enviado exitosamente a {email}")
        return True, None
        
    except Exception as e:
        error_msg = f"Error enviando email: {str(e)}"
        logger.error(f"❌ {error_msg}")
        return False, error_msg

@app.route('/webhook', methods=['POST'])
def webhook():
    """Endpoint que recibe POST requests y envía emails"""
    try:
        # Obtener datos JSON del request
        data = request.get_json()
        
        logger.info(f"📨 Webhook recibido: {data}")
        
        # Validar campos requeridos
        required_fields = ['nombre', 'email', 'fecha', 'estado']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    "success": False,
                    "error": f"Campo requerido faltante: {field}"
                }), 400
        
        # Enviar email
        success, error = send_email(
            data['nombre'],
            data['email'],
            data['fecha'],
            data['estado']
        )
        
        if success:
            return jsonify({
                "success": True,
                "message": f"Email enviado exitosamente a {data['email']}"
            }), 200
        else:
            return jsonify({
                "success": False,
                "error": error
            }), 500
            
    except Exception as e:
        logger.error(f"❌ Error procesando webhook: {str(e)}")
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({"status": "ok", "service": "SMTP Webhook Server"}), 200

if __name__ == '__main__':
    logger.info("=" * 60)
    logger.info("🚀 Iniciando servidor webhook SMTP")
    logger.info("=" * 60)
    logger.info(f"Host: {SMTP_HOST}")
    logger.info(f"Port: {SMTP_PORT}")
    logger.info(f"Username: {SMTP_USERNAME}")
    logger.info(f"Webhook URL: http://localhost:8080/webhook")
    logger.info("=" * 60)
    
    app.run(host='0.0.0.0', port=8080, debug=True)
