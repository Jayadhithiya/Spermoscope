import os
import sys

# Ensure parent directory is in python path
parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
mock_backend_dir = os.path.join(parent_dir, "mock_backend")
if mock_backend_dir not in sys.path:
    sys.path.insert(0, mock_backend_dir)

try:
    from gemini_analyzer import (
        analyze_semen_image,
        get_gemini_api_key,
        get_gemini_model,
        GEMINI_SYSTEM_PROMPT,
    )
except ImportError:
    # Direct import attempt
    from mock_backend.gemini_analyzer import (
        analyze_semen_image,
        get_gemini_api_key,
        get_gemini_model,
        GEMINI_SYSTEM_PROMPT,
    )
