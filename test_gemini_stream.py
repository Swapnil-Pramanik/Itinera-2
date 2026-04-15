import asyncio
import os
from dotenv import load_dotenv

load_dotenv()

async def test_stream():
    try:
        from google import genai
        client = genai.Client(api_key=os.environ.get("GEMINI_API_KEY"))
        print("Got client. Testing aio stream...")
        response = await client.aio.models.generate_content_stream(
            model='gemini-flash-latest', 
            contents='Count from 1 to 5'
        )
        async for chunk in response:
            print("Chunk:", chunk.text)
        print("Success!")
    except Exception as e:
        print("Failed:", e)

if __name__ == "__main__":
    asyncio.run(test_stream())
