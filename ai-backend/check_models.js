

const API_KEY = 'sk-A2TYCAakMiF23zw3oVZlJp27d9ysNg4ZiO7Oq7hXGGe7ey2Q';
const BASE_URL = 'https://api2.zhizhihu.cn/v1';

async function listModels() {
    try {
        const response = await fetch(`${BASE_URL}/models`, {
            headers: {
                'Authorization': `Bearer ${API_KEY}`
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        console.log('Total models:', data.data.length);

        // Filter for likely vision models
        const visionKeywords = ['vision', 'claude-3', 'gemini', 'gpt-4o', '4o'];
        const visionModels = data.data.filter(m =>
            visionKeywords.some(k => m.id.toLowerCase().includes(k))
        );

        console.log('\nPotential Vision Models:');
        visionModels.forEach(m => console.log(`- ${m.id}`));

        console.log('\nAll Models (first 20):');
        data.data.slice(0, 20).forEach(m => console.log(`- ${m.id}`));

    } catch (error) {
        console.error('Error fetching models:', error);
    }
}

listModels();
