const axios = require('axios');

const BASE_URL = 'https://jsonplaceholder.typicode.com';

describe('2-3. Модульное тестирование GET /users', () => {

  describe('Позитивные тест-кейсы', () => {
    test('GET /users — возвращает массив пользователей', async () => {
      const res = await axios.get(`${BASE_URL}/users`);
      expect(res.status).toBe(200);
      expect(Array.isArray(res.data)).toBe(true);
      expect(res.data.length).toBeGreaterThan(0);
    });

    test('GET /users/1 — возвращает конкретного пользователя', async () => {
      const res = await axios.get(`${BASE_URL}/users/1`);
      expect(res.status).toBe(200);
      expect(res.data).toHaveProperty('id', 1);
      expect(res.data).toHaveProperty('name');
      expect(res.data).toHaveProperty('email');
    });

    test('GET /users с заголовком Accept: application/json', async () => {
      const res = await axios.get(`${BASE_URL}/users`, {
        headers: { Accept: 'application/json' },
      });
      expect(res.status).toBe(200);
      expect(res.headers['content-type']).toContain('application/json');
    });

    test('GET /users/1 — содержит все обязательные поля', async () => {
      const res = await axios.get(`${BASE_URL}/users/1`);
      const requiredFields = ['id', 'name', 'username', 'email', 'address', 'phone', 'website', 'company'];
      requiredFields.forEach((field) => {
        expect(res.data).toHaveProperty(field);
      });
    });
  });


  describe('Негативные тест-кейсы', () => {
    test('GET /users/9999 — несуществующий пользователь возвращает 404', async () => {
      try {
        await axios.get(`${BASE_URL}/users/9999`);
      } catch (error) {
        expect(error.response.status).toBe(404);
      }
    });

    test('GET /users/abc — невалидный ID (строка вместо числа)', async () => {
      try {
        await axios.get(`${BASE_URL}/users/abc`);
      } catch (error) {
        expect(error.response.status).toBe(404);
      }
    });

    test('GET /users с невалидным заголовком Content-Type', async () => {
      const res = await axios.get(`${BASE_URL}/users`, {
        headers: { 'Content-Type': 'text/xml' },
      });
      expect(res.status).toBe(200);
      expect(res.headers['content-type']).toContain('application/json');
    });

    test('GET /users/-1 — отрицательный ID', async () => {
      try {
        await axios.get(`${BASE_URL}/users/-1`);
      } catch (error) {
        expect(error.response.status).toBe(404);
      }
    });

    test('GET /users/0 — нулевой ID', async () => {
      try {
        await axios.get(`${BASE_URL}/users/0`);
      } catch (error) {
        expect(error.response.status).toBe(404);
      }
    });
  });
});
