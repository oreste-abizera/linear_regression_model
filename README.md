# Education Prediction Linear Regression Model

## Mission
To bridge the education gap for rural students by providing access to high-quality learning materials and technologies and fostering their potential through exchange programs in advanced regions to inspire them to achieve great things and uplift their communities.

## Problem and Relevance
This project addresses the education gap in rural communities by building a machine learning model that predicts school life expectancy based on government expenditure patterns. The model helps policymakers understand the relationship between educational investment and outcomes, enabling better resource allocation decisions to bridge the education gap for rural students.

## Data Source
- The dataset used for this project is publicly available on Kaggle: [Education in Africa Dataset by Lydia70](https://www.kaggle.com/datasets/lydia70/education-in-africa)
- File used: `Education in General.csv` (located in `summative/linear_regression/`)

## Key Visualizations

### Distribution of School Life Expectancy (Male)
This histogram shows the distribution of school life expectancy for males across African countries in the dataset.
![Distribution of School Life Expectancy](summative/linear_regression/plots/school_life_expectancy_distribution.png)

### Top Features vs. School Life Expectancy
Scatter plots below show the relationship between the top three features and school life expectancy (male), with trend lines indicating correlation.
![Top Feature Scatter](summative/linear_regression/plots/top_feature_scatter.png)

## API Endpoint
**Public API URL:** https://education-prediction-api.onrender.com

**Swagger UI Documentation:** https://education-prediction-api.onrender.com/docs

**Prediction Endpoint:** POST /predict

### API Features:
- **Input Validation:** Enforces data types and range constraints for all inputs
- **CORS Support:** Cross-origin resource sharing enabled for mobile app integration
- **Error Handling:** Comprehensive error messages and validation
- **Confidence Levels:** Provides confidence assessment based on input quality

### Input Parameters:
- `primary_expenditure_usd`: Government expenditure on primary education (US$ millions, 0-100,000)
- `secondary_expenditure_usd`: Government expenditure on secondary education (US$ millions, 0-100,000)
- `tertiary_expenditure_usd`: Government expenditure on tertiary education (US$ millions, 0-100,000)
- `primary_expenditure_gdp`: Primary education as % of GDP (0-20%)
- `secondary_expenditure_gdp`: Secondary education as % of GDP (0-20%)
- `tertiary_expenditure_gdp`: Tertiary education as % of GDP (0-20%)
- `year`: Year of data (2010-2030)

### Output:
- `prediction`: Predicted school life expectancy in years
- `confidence`: Confidence level (High/Medium/Low)
- `message`: Analysis message

## Video Demo
**YouTube Link:** [Demo Video](https://youtu.be/T2eCIH3MgBA)

The video demonstrates:
- Mobile app predictions using the Flutter app
- API testing via Swagger UI
- Data type and range validation
- Model performance comparison
- Notebook walkthrough

## How to Run the Mobile App

### Prerequisites:
- Flutter SDK (version 3.8.1 or higher)
- Android Studio / VS Code with Flutter extension
- Android emulator or physical device

### Installation Steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/oreste-abizera/linear_regression_model.git
   cd linear_regression_model
   ```

2. **Navigate to Flutter app:**
   ```bash
   cd summative/FlutterApp
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```
4. **Run the app:**
   ```bash
   flutter run
   ```

### App Features:
- **7 Input Fields:** All required features for education prediction
- **Real-time Validation:** Input validation with helpful error messages
- **Beautiful UI:** Modern, organized interface with cards and proper spacing
- **Loading States:** Visual feedback during API calls
- **Error Handling:** Clear error messages for failed predictions
- **Results Display:** Formatted prediction results with confidence levels

## Project Structure
```
linear_regression_model/
├── README.md
├── summative/
│   ├── linear_regression/
│   │   ├── Education in General.csv           # Dataset
│   │   ├── models/
│   │   │   └── education_prediction_model.pkl # Saved model
│   │   └── multivariate.ipynb                 # Main ML notebook
│   ├── API/
│   │   ├── prediction.py                      # FastAPI application
│   │   └── requirements.txt                   # Python dependencies
│   └── FlutterApp/
│       ├── lib/
│       │   └── main.dart                      # Flutter app code
│       ├── pubspec.yaml                       # Flutter dependencies
│       └── README.md                          # Flutter setup guide
```

## Model Performance
- **Best Model:** Random Forest
- **R² Score:** 0.1990
- **RMSE:** 2.4924 years
- **MAE:** 1.7373 years

## Key Insights
1. Government investment in education shows strong correlation with educational outcomes
2. Secondary education expenditure has the highest impact on school life expectancy
3. Balanced investment across all education levels is crucial
4. The model can help policymakers make informed funding decisions

## Technologies Used
- **Machine Learning:** scikit-learn, pandas, numpy
- **API:** FastAPI, Pydantic, uvicorn
- **Mobile App:** Flutter, Dart
- **Deployment:** Render (API hosting)
- **Data:** [Education in Africa Dataset by Lydia70 on Kaggle](https://www.kaggle.com/datasets/lydia70/education-in-africa)
