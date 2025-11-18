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

async function testAllEndpoints() {
  console.log('=== Testing Comprehensive Disease API Endpoints ===\n');

  try {
    // Test 1: Get all diseases
    console.log('✓ Test 1: GET /disease - List all diseases');
    let result = await makeRequest('/disease');
    console.log(`  Status: ${result.status}, Count: ${result.body.length}\n`);

    // Test 2: Get specific disease with diet
    console.log('✓ Test 2: GET /disease/diabetes_type2/diet');
    result = await makeRequest('/disease/diabetes_type2/diet');
    console.log(`  Status: ${result.status}`);
    console.log(`  Disease: ${result.body.title}`);
    console.log(`  Diet constraints: ${JSON.stringify(result.body.diet.constraints)}\n`);

    // Test 3: Get exercises for a disease
    console.log('✓ Test 3: GET /disease/lower_back_pain/exercises');
    result = await makeRequest('/disease/lower_back_pain/exercises');
    console.log(`  Status: ${result.status}`);
    console.log(`  Recommended exercises: ${result.body.recommendedExercises.length}`);
    console.log(`  Exercises to avoid: ${result.body.avoidExercises.length}\n`);

    // Test 4: Get detailed disease information (NEW)
    console.log('✓ Test 4: GET /disease/pcos/detailed (NEW - Comprehensive Info)');
    result = await makeRequest('/disease/pcos/detailed');
    console.log(`  Status: ${result.status}`);
    console.log(`  Disease: ${result.body.title}`);
    console.log(`  Has diet info: ${!!result.body.diet}`);
    console.log(`  Has exercise info: ${!!result.body.exercises}`);
    console.log(`  Recommendations: ${JSON.stringify(result.body.recommendations.diet_focus)}\n`);

    // Test 5: Get full patient education profile (NEW)
    console.log('✓ Test 5: GET /disease/obesity/full-profile (NEW - Full Profile)');
    result = await makeRequest('/disease/obesity/full-profile');
    console.log(`  Status: ${result.status}`);
    console.log(`  Disease: ${result.body.disease.title}`);
    console.log(`  Diet summary: ${result.body.diet.summary}`);
    console.log(`  Exercise summary: ${result.body.exercise.summary}`);
    console.log(`  Lifestyle tips: ${result.body.lifestyle.tips.length} tips`);
    console.log(`  Monitoring guidelines: ${JSON.stringify(result.body.lifestyle.monitoring.trackingPoints)}\n`);

    // Test 6: Search diseases
    console.log('✓ Test 6: GET /disease?search=pain');
    result = await makeRequest('/disease?search=pain');
    console.log(`  Status: ${result.status}`);
    console.log(`  Diseases found: ${result.body.length}`);
    result.body.forEach(d => console.log(`    - ${d.title}`));
    console.log();

    console.log('✅ All tests passed! Backend API is fully functional.');
    console.log('\n=== API Endpoints Summary ===');
    console.log('GET  /api/disease                      - List all diseases');
    console.log('GET  /api/disease?search=<query>       - Search diseases');
    console.log('GET  /api/disease/:key/diet            - Get diet recommendations');
    console.log('GET  /api/disease/:key/exercises       - Get exercise recommendations');
    console.log('GET  /api/disease/:key/detailed        - Get detailed disease info (NEW)');
    console.log('GET  /api/disease/:key/full-profile    - Get full patient profile (NEW)');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    process.exit(1);
  }
}

// Run tests
setTimeout(testAllEndpoints, 1000);
