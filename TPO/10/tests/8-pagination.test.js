const axios = require('axios');

const BASE_URL = 'https://jsonplaceholder.typicode.com';

describe('8. Тестирование пагинации', () => {
  test('GET /posts?_page=1&_limit=10 — первая страница, 10 записей', async () => {
    const res = await axios.get(`${BASE_URL}/posts`, {
      params: { _page: 1, _limit: 10 },
    });
    expect(res.status).toBe(200);
    expect(res.data.length).toBe(10);
  });

  test('GET /posts?_page=2&_limit=10 — вторая страница, 10 записей', async () => {
    const res = await axios.get(`${BASE_URL}/posts`, {
      params: { _page: 2, _limit: 10 },
    });
    expect(res.status).toBe(200);
    expect(res.data.length).toBe(10);
    expect(res.data[0].id).toBeGreaterThan(10);
  });

  test('GET /posts?_page=1&_limit=5 — ограничение в 5 записей', async () => {
    const res = await axios.get(`${BASE_URL}/posts`, {
      params: { _page: 1, _limit: 5 },
    });
    expect(res.status).toBe(200);
    expect(res.data.length).toBe(5);
  });

  test('GET /posts?_page=1&_limit=1 — одна запись на страницу', async () => {
    const res = await axios.get(`${BASE_URL}/posts`, {
      params: { _page: 1, _limit: 1 },
    });
    expect(res.status).toBe(200);
    expect(res.data.length).toBe(1);
  });

  test('GET /posts?_page=999&_limit=10 — страница за пределами диапазона возвращает пустой массив', async () => {
    const res = await axios.get(`${BASE_URL}/posts`, {
      params: { _page: 999, _limit: 10 },
    });
    expect(res.status).toBe(200);
    expect(res.data.length).toBe(0);
    expect(Array.isArray(res.data)).toBe(true);
  });

  test('GET /posts?_page=0&_limit=10 — нулевая страница', async () => {
    const res = await axios.get(`${BASE_URL}/posts`, {
      params: { _page: 0, _limit: 10 },
    });
    expect(res.status).toBe(200);
    expect(Array.isArray(res.data)).toBe(true);
  });

  test('Данные на разных страницах не пересекаются', async () => {
    const page1 = await axios.get(`${BASE_URL}/posts`, {
      params: { _page: 1, _limit: 5 },
    });
    const page2 = await axios.get(`${BASE_URL}/posts`, {
      params: { _page: 2, _limit: 5 },
    });

    const ids1 = page1.data.map((p) => p.id);
    const ids2 = page2.data.map((p) => p.id);

    const intersection = ids1.filter((id) => ids2.includes(id));
    expect(intersection.length).toBe(0);
  });

  test('Ответ содержит заголовки с информацией о пагинации', async () => {
    const res = await axios.get(`${BASE_URL}/posts`, {
      params: { _page: 1, _limit: 10 },
    });
    expect(res.status).toBe(200);
    expect(res.headers).toHaveProperty('x-total-count');
    expect(parseInt(res.headers['x-total-count'])).toBeGreaterThan(0);
  });
});
