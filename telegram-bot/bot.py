import os
import requests
from telegram import Update
from telegram.ext import ApplicationBuilder, MessageHandler, filters, ContextTypes

OLLAMA_URL = os.getenv("OLLAMA_BASE_URL", "http://ollama:11434")
MODEL = os.getenv("OLLAMA_MODEL", "phi3:latest")

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    prompt = update.message.text

    try:
        r = requests.post(
            f"{OLLAMA_URL}/api/generate",
            json={
                "model": MODEL,
                "prompt": prompt,
                "stream": False
            },
            timeout=300
        )

        if r.status_code != 200:
            await update.message.reply_text(f"❌ Ollama error: {r.text}")
            return

        reply = r.json().get("response", "")
        await update.message.reply_text(reply or "⚠️ Empty response")

    except Exception as e:
        await update.message.reply_text(f"❌ Exception: {e}")

app = ApplicationBuilder().token(os.environ["TELEGRAM_TOKEN"]).build()
app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
app.run_polling()

