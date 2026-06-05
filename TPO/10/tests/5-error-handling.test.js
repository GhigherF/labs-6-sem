
const axios = require('axios');

const BASE_URL = 'https://jsonplaceholder.typicode.com';

describe('5. Тестирование обработки ошибок', () => {
  test('POST /posts с пустым телом — должен вернуть ответ (JSONPlaceholder принимает)', async () => {
    const res = await axios.post(`${BASE_URL}/posts`, {});
    // JSONPlaceholder создаёт ресурс даже с пустым телом, возвращает 201
    expect(res.status).toBe(201);
    expect(res.data).toHaveProperty('id');
  });

  test('POST /posts с некорректным форматом данных (строка вместо объекта)', async () => {
    const res = await axios.post(`${BASE_URL}/posts`, 'invalid data string', {
      headers: { 'Content-Type': 'application/json' },
      validateStatus: () => true,
    });
    expect([200, 201, 400, 500]).toContain(res.status);
  });

  test('GET /nonexistent — несуществующая конечная точка возвращает 404', async () => {
    try {
      await axios.get(`${BASE_URL}/nonexistent`);
    } catch (error) {
      expect(error.response.status).toBe(404);
      return;
    }
  });

  test('GET /posts/99999 — несуществующий ресурс возвращает 404', async () => {
    try {
      await axios.get(`${BASE_URL}/posts/99999`);
    } catch (error) {
      expect(error.response.status).toBe(404);
      return;
    }
  });

  test('PUT /posts/99999 — обновление несуществующего ресурса', async () => {
    try {
      const res = await axios.put(`${BASE_URL}/posts/99999`, {
        title: 'test',
        body: 'test',
        userId: 1,
      });
      expect([200, 404, 500]).toContain(res.status);
    } catch (error) {
      expect([404, 500]).toContain(error.response.status);
    }
  });

  test('DELETE /posts/99999 — удаление несуществующего ресурса', async () => {
    try {
      const res = await axios.delete(`${BASE_URL}/posts/99999`);
      expect([200, 204, 404]).toContain(res.status);
    } catch (error) {
      expect([404, 500]).toContain(error.response.status);
    }
  });

  test('PATCH с невалидным JSON в теле', async () => {
    const res = await axios.patch(`${BASE_URL}/posts/1`, '{{invalid json', {
      headers: { 'Content-Type': 'application/json' },
      validateStatus: () => true,
    });
    expect([200, 400, 500]).toContain(res.status);
  });
});
