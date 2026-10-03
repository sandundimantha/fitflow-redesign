from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from schemas import GeneratePlanRequest, GeneratePlanResponse
from generator import generate_custom_plan
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("fitflow-ai")

app = FastAPI(
    title="FitFlow AI Workout Plan Generation Microservice",
    description="Microservice powering intelligent, history-aware, equipment-constrained workout plan generation with individual exercise rationales.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health", tags=["Health"])
async def health_check():
    return {
        "status": "healthy",
        "service": "fitflow-ai-service",
        "version": "1.0.0"
    }

@app.post(
    "/generate-plan",
    response_model=GeneratePlanResponse,
    status_code=status.HTTP_200_OK,
    tags=["AI Workout Generation"]
)
async def generate_plan_endpoint(request: GeneratePlanRequest):
    try:
        logger.info(f"Generating workout plan for user {request.user_id}, goal: {request.goal}, equipment: {request.available_equipment}")
        plan = generate_custom_plan(request)
        return plan
    except Exception as e:
        logger.error(f"Error generating plan: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate workout plan: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8001, reload=True)
