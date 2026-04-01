import asyncio
import sys
import os

# Add the current directory to sys.path to import our modules
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), 'backend')))

from backend.core.ai import generate_destination_insights

async def test_ai():
    print("Testing AI insights for 'Paris, France'...")
    insights = await generate_destination_insights("Paris", "France")
    if insights:
        print("✅ SUCCESS! Generated insights:")
        import json
        print(json.dumps(insights, indent=2))
    else:
        print("❌ FAILED! Could not generate insights. Check if Ollama is running and gemma:4b is pulled.")

if __name__ == "__main__":
    asyncio.run(test_ai())
