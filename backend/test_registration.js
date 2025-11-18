const http = require('http');

function makeRequest(options, data) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        resolve({
          status: res.statusCode,
          body: body
        });
      });
    });
    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

async function test() {
  console.log('Testing registration endpoint...\n');
  
  const testData = {
    email: 'testuser2@example.com',
    password: 'password123',
    name: 'Test User 2',
    age: 28,
    gender: 'female',
    height_cm: 165,
    weight_kg: 65,
    disease: 'pcos',
    diet_preference: 'vegan',
    fitness_goal: 'muscle_gain',
    activity_level: 'very_active',
    meal_type: 'low_carb',
    target_calories: 2400
  };

  const options = {
    hostname: 'localhost',
    port: 4000,
    path: '/api/auth/register',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': JSON.stringify(testData).length
    }
  };

  try {
    const result = await makeRequest(options, testData);
    console.log('Status:', result.status);
    console.log('Response:', result.body);
    
    if (result.status === 200) {
      console.log('\n✅ Registration successful!');
    } else {
      console.log('\n❌ Registration failed!');
    }
  } catch (e) {
    console.error('Error:', e.message);
    console.error('Stack:', e.stack);
    process.exit(1);
  }
}

test();
