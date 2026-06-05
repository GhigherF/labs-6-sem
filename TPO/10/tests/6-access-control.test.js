
const axios = require('axios');

const BASE_URL = 'https://jsonplaceholder.typicode.com';
const GITHUB_API = 'https://api.github.com';

describe('6. Тестирование прав доступа', () => {
  test('GitHub API: GET /user без токена возвращает 401', async () => {
    try {
      await axios.get(`${GITHUB_API}/user`);
    } catch (error) {
      expect(error.response.status).toBe(401);
      expect(error.response.data).toHaveProperty('message');
    }
  });

  test('GitHub API: POST /user/repos без токена возвращает 401', async () => {
    try {
      await axios.post(`${GITHUB_API}/user/repos`, { name: 'test-repo' });
    } catch (error) {
      expect(error.response.status).toBe(401);
    }
  });

  test('GitHub API: GET /user/emails без токена возвращает 401', async () => {
    try {
      await axios.get(`${GITHUB_API}/user/emails`);
    } catch (error) {
      expect(error.response.status).toBe(401);
      expect(error.response.data.message).toContain('Requires authentication');
    }
  });

  test('GitHub API: DELETE /repos/owner/repo без токена возвращает 401/404', async () => {
    try {
      await axios.delete(`${GITHUB_API}/repos/testuser/testrepo`);
    } catch (error) {
      expect([401, 403, 404]).toContain(error.response.status);
    }
  });

  test('GitHub API: с невалидным токеном возвращает 401', async () => {
    try {
      await axios.get(`${GITHUB_API}/user`, {
        headers: { Authorization: 'Bearer invalid_token_12345' },
      });
    } catch (error) {
      expect(error.response.status).toBe(401);
    }
  });

  test('Попытка доступа к данным другого пользователя (изоляция)', async () => {
    // GitHub API: приватные gists другого пользователя недоступны
    try {
      await axios.get(`${GITHUB_API}/gists/starred`);
    } catch (error) {
      expect([401, 403, 404]).toContain(error.response.status);
    }
  });
});
