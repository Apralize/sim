#!/usr/bin/env python3
"""
Script para probar configuración SMTP antes de usarla en SIM Studio
"""
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# ============================================
# CONFIGURA ESTOS VALORES ANTES DE EJECUTAR
# ============================================
SMTP_HOST = "sandbox.smtp.mailtrap.io"
SMTP_PORT = 587
SMTP_USERNAME = "7c549514d5e656"
SMTP_PASSWORD = "7cf0c95869f155"
FROM_EMAIL = "fernando.apralize.tests@gmail.com"
TO_EMAIL = "multiplequeries.fergv@gmail.com"  # Email de prueba

def test_smtp_connection():
    """Prueba la conexión SMTP"""
    print("=" * 60)
    print("PRUEBA DE CONFIGURACIÓN SMTP")
    print("=" * 60)
    print(f"\nHost: {SMTP_HOST}")
    print(f"Port: {SMTP_PORT}")
    print(f"Username: {SMTP_USERNAME}")
    print(f"From: {FROM_EMAIL}")
    print(f"To: {TO_EMAIL}")
    print("\n" + "-" * 60)
    
    try:
        # Crear mensaje
        message = MIMEMultipart()
        message["From"] = FROM_EMAIL
        message["To"] = TO_EMAIL
        message["Subject"] = "Prueba de SMTP - Reservación de Cita"
        
        body = "Fernando Pérez el estado de su cita se actualiza como \"confirmado\" para 2026-01-20 10:00 AM en su centro de atención."
        message.attach(MIMEText(body, "plain"))
        
        # Conectar al servidor SMTP
        print("\n1. Conectando al servidor SMTP...")
        server = smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=10)
        print("   ✓ Conexión establecida")
        
        # Iniciar TLS
        print("\n2. Iniciando encriptación TLS...")
        server.starttls()
        print("   ✓ TLS activado")
        
        # Login
        print("\n3. Autenticando...")
        server.login(SMTP_USERNAME, SMTP_PASSWORD)
        print("   ✓ Autenticación exitosa")
        
        # Enviar email
        print("\n4. Enviando email...")
        server.send_message(message)
        print("   ✓ Email enviado exitosamente")
        
        # Cerrar conexión
        server.quit()
        
        print("\n" + "=" * 60)
        print("✅ PRUEBA EXITOSA - SMTP FUNCIONA CORRECTAMENTE")
        print("=" * 60)
        print(f"\nRevisa tu bandeja de entrada: {TO_EMAIL}")
        print("Puedes usar esta configuración en SIM Studio.")
        
        return True
        
    except smtplib.SMTPAuthenticationError as e:
        print("\n" + "=" * 60)
        print("❌ ERROR DE AUTENTICACIÓN")
        print("=" * 60)
        print("\nPosibles causas:")
        print("1. Contraseña incorrecta")
        print("2. Gmail: Necesitas activar verificación en 2 pasos")
        print("3. Gmail: Necesitas generar una contraseña de aplicación")
        print(f"\nError técnico: {e}")
        return False
        
    except smtplib.SMTPConnectError as e:
        print("\n" + "=" * 60)
        print("❌ ERROR DE CONEXIÓN")
        print("=" * 60)
        print("\nNo se pudo conectar al servidor SMTP.")
        print(f"Verifica el host ({SMTP_HOST}) y el puerto ({SMTP_PORT})")
        print(f"\nError técnico: {e}")
        return False
        
    except Exception as e:
        print("\n" + "=" * 60)
        print("❌ ERROR INESPERADO")
        print("=" * 60)
        print(f"\nError: {e}")
        print(f"Tipo: {type(e).__name__}")
        return False

if __name__ == "__main__":
    test_smtp_connection()
