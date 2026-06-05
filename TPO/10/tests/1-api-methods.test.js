const axios = require('axios');

const BASE_URL = 'https://jsonplaceholder.typicode.com';

describe('1. Список доступных методов API', () => {
  const resources = ['posts', 'comments', 'albums', 'photos', 'todos', 'users'];

  resources.forEach((resource) => {
    test(`GET /${resource} должен вернуть 200`, async () => {
      const res = await axios.get(`${BASE_URL}/${resource}`);
      expect(res.status).toBe(200);
      expect(Array.isArray(res.data)).toBe(true);
    });
  });

  test('GET /posts/1 — получение одного ресурса', async () => {
    const res = await axios.get(`${BASE_URL}/posts/1`);
    expect(res.status).toBe(200);
    expect(res.data).toHaveProperty('id', 1);
  });

  test('POST /posts — создание ресурса', async () => {
    const res = await axios.post(`${BASE_URL}/posts`, {
      title: 'test',
      body: 'test body',
      userId: 1,
    });
    expect(res.status).toBe(201);
  });

  test('PUT /posts/1 — обновление ресурса', async () => {
    const res = await axios.put(`${BASE_URL}/posts/1`, {
      id: 1,
      title: 'updated',
      body: 'updated body',
      userId: 1,
    });
    expect(res.status).toBe(200);
  });

  test('PATCH /posts/1 — частичное обновление ресурса', async () => {
    const res = await axios.patch(`${BASE_URL}/posts/1`, {
      title: 'patched title',
    });
    expect(res.status).toBe(200);
  });

  test('DELETE /posts/1 — удаление ресурса', async () => {
    const res = await axios.delete(`${BASE_URL}/posts/1`);
    expect(res.status).toBe(200);
  });
});
