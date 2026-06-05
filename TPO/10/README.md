# Лабораторная работа 10 — Тестирование API

## Используемые API
- **JSONPlaceholder** (https://jsonplaceholder.typicode.com) — основной публичный API для тестирования
- **ReqRes.in** (https://reqres.in) — для тестирования валидации
- **GitHub API** (https://api.github.com) — для тестирования прав доступа

## Технологии
- **Node.js** — среда выполнения
- **Jest** — фреймворк для тестирования
- **Axios** — HTTP-клиент

## Структура тестов
| Файл | Задание | Описание |
|------|---------|----------|
| `1-api-methods.test.js` | 1 | Список доступных методов API |
| `2-unit-tests.test.js` | 2-3 | Модульное тестирование (позитивные/негативные кейсы) |
| `4-crud-integration.test.js` | 4 | Интеграционное тестирование CRUD |
| `5-error-handling.test.js` | 5 | Тестирование обработки ошибок |
| `6-access-control.test.js` | 6 | Тестирование прав доступа |
| `7-data-validation.test.js` | 7 | Тестирование валидации данных |
| `8-pagination.test.js` | 8 | Тестирование пагинации |

## Установка и запуск

```bash
npm install
npm test
```

## Запуск отдельного файла тестов

```bash
npx jest tests/1-api-methods.test.js --verbose
```
