import asyncio
import os
from core.ai import generate_budget_insights

async def test():
    # Mocking GEMINI_API_KEY if not exists (it should be in env or provided)
    res = await generate_budget_insights(
        'Seoul', 
        'South Korea', 
        'New Delhi', 
        5, 
        [{'title': 'Gyeongbokgung Palace Visit', 'category': 'SIGHTSEEING'}]
    )
    print("RESULT:", res)

if __name__ == "__main__":
    asyncio.run(test())
