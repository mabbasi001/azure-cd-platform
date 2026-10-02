import http from "k6/http";
import { check } from "k6";

export const options = {
  vus: 5,
  duration: "30s",
  thresholds: {
    http_req_duration: ["p(95)<800"],
    http_req_failed: ["rate<0.01"],
  },
};

export default function () {
  const base = __ENV.BASE_URL;
  const res = http.get(`${base}/api/tags`);
  check(res, { "status is 200": (r) => r.status === 200 });
}
