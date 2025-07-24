from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, validator
import pickle
import numpy as np
import joblib
from typing import Optional

# Initialize FastAPI app
app = FastAPI(
    title="Education Prediction API",
    description="API for predicting school life expectancy based on government expenditure",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic model for input validation
class EducationPredictionInput(BaseModel):
    primary_expenditure_usd: float = Field(
        ..., 
        ge=0, 
        le=100000, 
        description="Government expenditure on primary education in US$ (millions)"
    )
    secondary_expenditure_usd: float = Field(
        ..., 
        ge=0, 
        le=100000, 
        description="Government expenditure on secondary education in US$ (millions)"
    )
    tertiary_expenditure_usd: float = Field(
        ..., 
        ge=0, 
        le=100000, 
        description="Government expenditure on tertiary education in US$ (millions)"
    )
    primary_expenditure_gdp: float = Field(
        ..., 
        ge=0, 
        le=20, 
        description="Government expenditure on primary education as percentage of GDP"
    )
    secondary_expenditure_gdp: float = Field(
        ..., 
        ge=0, 
        le=20, 
        description="Government expenditure on secondary education as percentage of GDP"
    )
    tertiary_expenditure_gdp: float = Field(
        ..., 
        ge=0, 
        le=20, 
        description="Government expenditure on tertiary education as percentage of GDP"
    )
    year: int = Field(
        ..., 
        ge=2010, 
        le=2030, 
        description="Year of the data"
    )

    @validator('year')
    def validate_year(cls, v):
        if v < 2010 or v > 2030:
            raise ValueError('Year must be between 2010 and 2030')
        return v

# Pydantic model for response
class EducationPredictionResponse(BaseModel):
    prediction: float
    confidence: str
    message: str

# Load the model and scaler
try:
    with open('../linear_regression/models/education_prediction_model.pkl', 'rb') as file:
        model = pickle.load(file)
    print("Model loaded successfully!")
except Exception as e:
    print(f"Error loading model: {e}")
    model = None

# Feature names in the order expected by the model
FEATURE_NAMES = [
    'Government expenditure on primary education, US$ (millions)',
    'Government expenditure on secondary education, US$ (millions)',
    'Government expenditure on tertiary education, US$ (millions)',
    'Government expenditure on primary education as a percentage of GDP (%)',
    'Government expenditure on secondary education as a percentage of GDP (%)',
    'Government expenditure on tertiary education as a percentage of GDP (%)',
    'Year',
    'Total_education_expenditure',
    'Total_education_GDP_percentage',
    'Tertiary_primary_ratio'
]

def calculate_derived_features(input_data):
    """Calculate derived features based on input data"""
    primary_usd = input_data.primary_expenditure_usd
    secondary_usd = input_data.secondary_expenditure_usd
    tertiary_usd = input_data.tertiary_expenditure_usd
    primary_gdp = input_data.primary_expenditure_gdp
    secondary_gdp = input_data.secondary_expenditure_gdp
    tertiary_gdp = input_data.tertiary_expenditure_gdp
    year = input_data.year
    
    # Calculate derived features
    total_expenditure = primary_usd + secondary_usd + tertiary_usd
    total_gdp_percentage = primary_gdp + secondary_gdp + tertiary_gdp
    tertiary_primary_ratio = tertiary_usd / (primary_usd + 1)  # Add 1 to avoid division by zero
    
    return [
        primary_usd,
        secondary_usd,
        tertiary_usd,
        primary_gdp,
        secondary_gdp,
        tertiary_gdp,
        year,
        total_expenditure,
        total_gdp_percentage,
        tertiary_primary_ratio
    ]

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Education Prediction API",
        "version": "1.0.0",
        "endpoints": {
            "predict": "/predict",
            "docs": "/docs"
        }
    }

@app.post("/predict", response_model=EducationPredictionResponse)
async def predict_education_outcome(input_data: EducationPredictionInput):
    """
    Predict school life expectancy based on government expenditure data
    
    This endpoint takes government expenditure data and predicts the expected
    school life expectancy for male students from primary to tertiary education.
    """
    if model is None:
        raise HTTPException(status_code=500, detail="Model not loaded")
    
    try:
        # Calculate all features including derived ones
        features = calculate_derived_features(input_data)
        
        # Reshape for prediction
        features_array = np.array(features).reshape(1, -1)
        
        # Make prediction
        prediction = model.predict(features_array)[0]
        
        # Determine confidence level based on input quality
        total_expenditure = input_data.primary_expenditure_usd + input_data.secondary_expenditure_usd + input_data.tertiary_expenditure_usd
        total_gdp = input_data.primary_expenditure_gdp + input_data.secondary_expenditure_gdp + input_data.tertiary_expenditure_gdp
        
        if total_expenditure > 1000 and total_gdp > 3:
            confidence = "High"
            message = "Based on substantial government investment in education"
        elif total_expenditure > 500 and total_gdp > 2:
            confidence = "Medium"
            message = "Based on moderate government investment in education"
        else:
            confidence = "Low"
            message = "Based on limited government investment in education"
        
        return EducationPredictionResponse(
            prediction=round(prediction, 2),
            confidence=confidence,
            message=message
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "timestamp": "2024-01-01T00:00:00Z"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
