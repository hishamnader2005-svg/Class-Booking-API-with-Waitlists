from fastapi import FastAPI

app = FastAPI(title="Class Booking API")


@app.get("/health")
def health():
    return {"status": "ok"}