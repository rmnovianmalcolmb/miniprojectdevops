import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 100 },
    { duration: '1m',  target: 500 },
    { duration: '1m',  target: 1000 },
    { duration: '2m',  target: 1000 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const BASE_URL = __ENV.BASE_URL || 'http://20.24.192.173';

  const frontendRes = http.get(`${BASE_URL}/`);
  check(frontendRes, {
    'frontend returns 200': (r) => r.status === 200,
  });

  const backendRes = http.get(`${BASE_URL}/api/health`);
  check(backendRes, {
    'backend returns 200': (r) => r.status === 200,
    'backend healthy': (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.success === true;
      } catch (e) {
        return false;
      }
    },
    'hostname exists': (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.hostname !== undefined;
      } catch (e) {
        return false;
      }
    },
  });

  sleep(1);
}