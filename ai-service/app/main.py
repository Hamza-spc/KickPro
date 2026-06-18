from fastapi import FastAPI

app = FastAPI(title="KickPro AI Service", version="0.1.0")


@app.get("/health")
def health():
    return {
        "success": True,
        "data": {"status": "ok"},
        "message": "AI service is running",
    }
