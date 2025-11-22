const http = require('http');

const BASE_URL = 'http://localhost:4000/api';

function makeRequest(path, method = 'GET') {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 4000,
      path: `/api${path}`,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({
            status: res.statusCode,
            body: parsed
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            body: data
          });
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
}

async function testDietEndpoints() {
  console.log('Testing Diet API Endpoints...\n');

  try {
    // Test 1: Get all diseases
    console.log('1. GET /disease - List all diseases');
    let result = await makeRequest('/disease');
    console.log(`Status: ${result.status}`);
    console.log(`Diseases count: ${result.body.length}\n`);

    // Test 2: Get diabetes diet rules
    console.log('2. GET /disease/diabetes_type2/diet - Get Diabetes Diet Rules');
    result = await makeRequest('/disease/diabetes_type2/diet');
    console.log(`Status: ${result.status}`);
    if (result.body.diet) {
      console.log(`Disease: ${result.body.title}`);
      console.log(`Avoid foods: ${result.body.diet.avoid_foods.slice(0, 3).join(', ')}...`);
      console.log(`Recommended foods: ${result.body.diet.recommended_foods.slice(0, 3).join(', ')}...`);
      console.log(`Macros: ${JSON.stringify(result.body.diet.macros)}`);
    }
    console.log();

    // Test 3: Get hypertension diet rules
    console.log('3. GET /disease/hypertension/diet - Get Hypertension Diet Rules');
    result = await makeRequest('/disease/hypertension/diet');
    console.log(`Status: ${result.status}`);
    if (result.body.diet) {
      console.log(`Disease: ${result.body.title}`);
      console.log(`Avoid foods: ${result.body.diet.avoid_foods.slice(0, 3).join(', ')}...`);
      console.log(`Recommended foods: ${result.body.diet.recommended_foods.slice(0, 3).join(', ')}...`);
      if (result.body.diet.constraints) {
        console.log(`Sodium limit: ${result.body.diet.constraints.sodium_limit_mg} mg`);
        console.log(`Potassium target: ${result.body.diet.constraints.potassium_target_mg} mg`);
      }
    }
    console.log();

    // Test 4: Get PCOS diet rules
    console.log('4. GET /disease/pcos/diet - Get PCOS Diet Rules');
    result = await makeRequest('/disease/pcos/diet');
    console.log(`Status: ${result.status}`);
    if (result.body.diet) {
      console.log(`Disease: ${result.body.title}`);
      console.log(`Protein %: ${result.body.diet.macros.protein_pct.join('-')}%`);
      console.log(`Focus: ${result.body.diet.constraints.focus}`);
    }
    console.log();

    // Test 5: Search diseases
    console.log('5. GET /disease?search=pain - Search for diseases');
    result = await makeRequest('/disease?search=pain');
    console.log(`Status: ${result.status}`);
    console.log(`Diseases found: ${result.body.length}`);
    result.body.forEach(d => {
      console.log(`  - ${d.title}`);
    });
    console.log();

    console.log('✅ All tests completed!');
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

// Wait a moment for server to start, then run tests
setTimeout(testDietEndpoints, 2000);
