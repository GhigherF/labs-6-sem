
const axios = require('axios');

const BASE_URL = 'https://jsonplaceholder.typicode.com';

describe('4. Интеграционное тестирование CRUD /users', () => {
  let createdUserId;

  test('POST /users — создание нового пользователя (201)', async () => {
    const newUser = {
      name: 'Test User',
      username: 'testuser',
      email: 'test@example.com',
      phone: '1-234-567-8900',
      website: 'test.com',
      address: {
        street: 'Test St',
        suite: 'Apt. 1',
        city: 'Testville',
        zipcode: '12345',
      },
      company: {
        name: 'Test Corp',
      },
    };

    const res = await axios.post(`${BASE_URL}/users`, newUser);
    expect(res.status).toBe(201);
    expect(res.data).toHaveProperty('id');
    expect(res.data.name).toBe('Test User');
    expect(res.data.email).toBe('test@example.com');
    createdUserId = res.data.id;
  });

  test('GET /users/:id — чтение созданного пользователя (200)', async () => {
    const res = await axios.get(`${BASE_URL}/users/1`);
    expect(res.status).toBe(200);
    expect(res.data).toHaveProperty('id', 1);
    expect(res.data).toHaveProperty('name');
    expect(res.data).toHaveProperty('email');
    expect(res.data).toHaveProperty('username');
  });

  test('PUT /users/1 — обновление пользователя (200)', async () => {
    const updatedData = {
      id: 1,
      name: 'Updated User',
      username: 'updateduser',
      email: 'updated@example.com',
      phone: '9-876-543-2100',
      website: 'updated.com',
      address: {
        street: 'Updated St',
        suite: 'Apt. 2',
        city: 'Updateville',
        zipcode: '54321',
      },
      company: {
        name: 'Updated Corp',
      },
    };

    const res = await axios.put(`${BASE_URL}/users/1`, updatedData);
    expect(res.status).toBe(200);
    expect(res.data.email).toBe('updated@example.com');
    expect(res.data.name).toBe('Updated User');
  });

  test('PATCH /users/1 — частичное обновление email (200)', async () => {
    const res = await axios.patch(`${BASE_URL}/users/1`, {
      email: 'patched@example.com',
    });
    expect(res.status).toBe(200);
    expect(res.data.email).toBe('patched@example.com');
  });

  test('DELETE /users/1 — удаление пользователя (200)', async () => {
    const res = await axios.delete(`${BASE_URL}/users/1`);
    expect(res.status).toBe(200);
  });
});
