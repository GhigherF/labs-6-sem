const axios = require('axios');

const BASE_URL = 'https://jsonplaceholder.typicode.com';
const DUMMYJSON_URL = 'https://dummyjson.com';

describe('7. Тестирование валидации данных', () => {
  describe('JSONPlaceholder — проверка поведения при некорректных данных', () => {
    test('POST /posts со слишком длинной строкой в поле title', async () => {
      const longTitle = 'A'.repeat(10000);
      const res = await axios.post(`${BASE_URL}/posts`, {
        title: longTitle,
        body: 'test',
        userId: 1,
      });
      expect(res.status).toBe(201);
      expect(res.data.title).toBe(longTitle);
    });

    test('POST /posts с числом вместо строки в поле title', async () => {
      const res = await axios.post(`${BASE_URL}/posts`, {
        title: 12345,
        body: 'test',
        userId: 1,
      });
      expect(res.status).toBe(201);
      expect(res.data.title).toBe(12345);
    });

    test('POST /posts с отрицательным userId', async () => {
      const res = await axios.post(`${BASE_URL}/posts`, {
        title: 'test',
        body: 'test',
        userId: -999,
      });
      expect(res.status).toBe(201);
      expect(res.data.userId).toBe(-999);
    });

    test('POST /posts без обязательного поля userId', async () => {
      const res = await axios.post(`${BASE_URL}/posts`, {
        title: 'test',
        body: 'test',
      });
      expect(res.status).toBe(201);
    });

    test('POST /posts с числом за пределами допустимого диапазона', async () => {
      const res = await axios.post(`${BASE_URL}/posts`, {
        title: 'test',
        body: 'test',
        userId: Number.MAX_SAFE_INTEGER + 1,
      });
      expect(res.status).toBe(201);
    });
  });

  describe('DummyJSON — реальная валидация', () => {
    test('POST /auth/login без поля password возвращает 400 и сообщение "Username and password required"', async () => {
      const res = await axios.post(`${DUMMYJSON_URL}/auth/login`, {
        username: 'emilys',
      }, {
        validateStatus: () => true,
      });

      expect(res.status).toBe(400);
      expect(res.data.message).toBe('Username and password required');
    });

    test('POST /auth/login без поля username возвращает 400 и сообщение "Username and password required"', async () => {
      const res = await axios.post(`${DUMMYJSON_URL}/auth/login`, {
        password: 'emilyspass',
      }, {
        validateStatus: () => true,
      });

      expect(res.status).toBe(400);
      expect(res.data.message).toBe('Username and password required');
    });

    test('POST /auth/login с неверным паролем возвращает 400 и сообщение "Invalid credentials"', async () => {
      const res = await axios.post(`${DUMMYJSON_URL}/auth/login`, {
        username: 'emilys',
        password: 'wrong-password',
      }, {
        validateStatus: () => true,
      });

      expect(res.status).toBe(400);
      expect(res.data.message).toBe('Invalid credentials');
    });

    test('POST /auth/login с неверным username возвращает 400 и сообщение "Invalid credentials"', async () => {
      const res = await axios.post(`${DUMMYJSON_URL}/auth/login`, {
        username: 'unknown-user',
        password: 'emilyspass',
      }, {
        validateStatus: () => true,
      });

      expect(res.status).toBe(400);
      expect(res.data.message).toBe('Invalid credentials');
    });
  });
});
