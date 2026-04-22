from fastapi import FastAPI

app = FastAPI(title="SkinLens API")


@app.get("/api/v1/health")
def health() -> dict:
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8080)
