const nf = require('node-fetch');
const fetch = nf.default || nf;
(async ()=>{
  try{
    const base = 'http://localhost:4000';
    console.log('Calling GET /api/disease');
    const dsRes = await fetch(base + '/api/disease');
    const ds = await dsRes.json();
    console.log(JSON.stringify(ds, null, 2));

    const key = ds && ds[0] && ds[0].keyname ? ds[0].keyname : 'knee_pain';
    console.log('\nCalling GET /api/disease/' + key + '/exercises');
    const exRes = await fetch(base + '/api/disease/' + encodeURIComponent(key) + '/exercises');
    const ex = await exRes.json();
    console.log(JSON.stringify(ex, null, 2));

    console.log('\nLogging in as test user');
    const loginRes = await fetch(base + '/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'test@example.com', password: 'test123' })
    });
    const login = await loginRes.json();
    console.log(JSON.stringify(login, null, 2));

    if (!login.accessToken) {
      console.error('Login failed, cannot request meal plan');
      process.exit(1);
    }

    console.log('\nRequesting POST /api/mealplan/generate');
    const planRes = await fetch(base + '/api/mealplan/generate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + login.accessToken },
      body: JSON.stringify({})
    });
    const plan = await planRes.json();
    console.log(JSON.stringify(plan, null, 2));

    console.log('\nDone.');
  } catch (e) {
    console.error('Error in test script', e);
    process.exit(1);
  }
})();
