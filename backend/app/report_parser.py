"""
Medical Report Parser
Extracts and analyzes data from medical reports (PDF, images)
"""

import os
import logging
from typing import Dict, Any
import re

logger = logging.getLogger(__name__)


async def parse_report(file_path: str) -> Dict[str, Any]:
    """
    Parse medical report and extract key information

    Args:
        file_path: Path to the medical report file

    Returns:
        Dictionary containing parsed data
    """

    file_extension = os.path.splitext(file_path)[1].lower()

    try:
        if file_extension == '.pdf':
            return await parse_pdf_report(file_path)
        elif file_extension in ['.jpg', '.jpeg', '.png']:
            return await parse_image_report(file_path)
        else:
            return {
                "error": f"Unsupported file type: {file_extension}"
            }
    except Exception as e:
        logger.error(f"Error parsing report: {e}")
        return {
            "error": str(e)
        }


async def parse_pdf_report(file_path: str) -> Dict[str, Any]:
    """Parse PDF medical report"""

    try:
        from PyPDF2 import PdfReader

        reader = PdfReader(file_path)
        text = ""

        # Extract text from all pages
        for page in reader.pages:
            text += page.extract_text()

        # Analyze the extracted text
        analysis = analyze_medical_text(text)

        return {
            "status": "success",
            "file_type": "pdf",
            "pages": len(reader.pages),
            "raw_text": text,
            "analysis": analysis
        }

    except Exception as e:
        logger.error(f"Error parsing PDF: {e}")
        return {
            "status": "error",
            "error": str(e)
        }


async def parse_image_report(file_path: str) -> Dict[str, Any]:
    """Parse image-based medical report using OCR"""

    try:
        import pytesseract
        from PIL import Image

        # Open image
        image = Image.open(file_path)

        # Perform OCR
        text = pytesseract.image_to_string(image)

        # Analyze the extracted text
        analysis = analyze_medical_text(text)

        return {
            "status": "success",
            "file_type": "image",
            "dimensions": image.size,
            "raw_text": text,
            "analysis": analysis
        }

    except Exception as e:
        logger.error(f"Error parsing image: {e}")
        return {
            "status": "error",
            "error": str(e)
        }


def analyze_medical_text(text: str) -> Dict[str, Any]:
    """
    Analyze medical report text and extract key information
    """

    analysis = {
        "test_type": detect_test_type(text),
        "abnormal_values": extract_abnormal_values(text),
        "key_findings": extract_key_findings(text),
        "date": extract_date(text),
    }

    return analysis


def detect_test_type(text: str) -> str:
    """Detect the type of medical test"""

    text_lower = text.lower()

    # Common test types
    test_types = {
        "blood test": ["blood test", "complete blood count", "cbc", "hemoglobin"],
        "lipid profile": ["lipid", "cholesterol", "triglycerides", "hdl", "ldl"],
        "liver function": ["liver function", "sgpt", "sgot", "alt", "ast", "bilirubin"],
        "kidney function": ["kidney", "creatinine", "urea", "bun"],
        "thyroid": ["thyroid", "tsh", "t3", "t4"],
        "diabetes": ["glucose", "hba1c", "diabetes", "blood sugar"],
        "urine test": ["urine", "urinalysis"],
        "x-ray": ["x-ray", "radiograph"],
        "mri": ["mri", "magnetic resonance"],
        "ct scan": ["ct scan", "computed tomography"],
    }

    for test_type, keywords in test_types.items():
        if any(keyword in text_lower for keyword in keywords):
            return test_type

    return "Unknown"


def extract_abnormal_values(text: str) -> list:
    """Extract values that appear to be out of normal range"""

    abnormal = []

    # Look for common indicators of abnormal values
    abnormal_indicators = [
        r"(high|elevated|increased)\s*:?\s*(\w+)",
        r"(low|decreased|reduced)\s*:?\s*(\w+)",
        r"(\w+)\s*:?\s*(high|low|elevated|abnormal)",
    ]

    for pattern in abnormal_indicators:
        matches = re.finditer(pattern, text, re.IGNORECASE)
        for match in matches:
            abnormal.append(match.group(0))

    return abnormal


def extract_key_findings(text: str) -> list:
    """Extract key findings from the report"""

    findings = []

    # Look for sections with findings
    finding_indicators = [
        r"findings?:(.+?)(?:\n\n|\Z)",
        r"impression:(.+?)(?:\n\n|\Z)",
        r"conclusion:(.+?)(?:\n\n|\Z)",
        r"remarks?:(.+?)(?:\n\n|\Z)",
    ]

    for pattern in finding_indicators:
        matches = re.finditer(pattern, text, re.IGNORECASE | re.DOTALL)
        for match in matches:
            finding = match.group(1).strip()
            if finding:
                findings.append(finding)

    return findings


def extract_date(text: str) -> str:
    """Extract date from report"""

    # Common date patterns
    date_patterns = [
        r"\d{1,2}[-/]\d{1,2}[-/]\d{2,4}",
        r"\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*\s+\d{2,4}",
    ]

    for pattern in date_patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            return match.group(0)

    return "Not found"


async def get_ai_analysis(report_data: Dict[str, Any]) -> str:
    """
    Get AI-powered analysis of the medical report
    Uses OpenAI to provide detailed insights
    """

    from openai import AsyncOpenAI

    client = AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY"))

    try:
        prompt = f"""Analyze this medical report data:

Test Type: {report_data.get('analysis', {}).get('test_type')}
Abnormal Values: {report_data.get('analysis', {}).get('abnormal_values')}
Key Findings: {report_data.get('analysis', {}).get('key_findings')}

Provide a brief, patient-friendly explanation of:
1. What this test shows
2. Any concerning findings
3. General recommendations (always emphasize consulting a doctor)
"""

        response = await client.chat.completions.create(
            model="gpt-4-turbo-preview",
            messages=[
                {"role": "system", "content": "You are a medical AI assistant helping patients understand their test results."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=300
        )

        return response.choices[0].message.content

    except Exception as e:
        logger.error(f"Error getting AI analysis: {e}")
        return "Unable to generate AI analysis at this time."
