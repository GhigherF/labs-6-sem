# Телефонный справочник - Express приложение

## Установка зависимостей

```bash
cd c:\labs\labs-6-sem\PSKP\4
npm install
```

## Запуск приложения

```bash
npm start
```

Сервер запустится на http://localhost:3000

## Структура проекта

```
4/
├── server.js              # Главный файл сервера
├── package.json           # Зависимости
├── phonebook.json         # База данных (JSON)
├── views/
│   ├── layouts/
│   │   └── main.handlebars      # Общий макет
│   ├── partials/
│   │   └── contactList.handlebars  # Partial для списка контактов
│   ├── index.handlebars    # GET:/ - главная страница
│   ├── add.handlebars      # GET:/Add - форма добавления
│   └── update.handlebars   # GET:/Update - форма изменения
└── public/                 # Статические файлы (если нужны)
```

## Как работает приложение

### 1. Маршруты (Routes)

**GET:/**
- Отображает список всех контактов
- Каждый контакт - кликабельная кнопка-ссылка
- Кнопка "Добавить" внизу

**GET:/Add**
- Форма для добавления нового контакта
- Список контактов заблокирован (disabled)
- Поля: Имя, Телефон
- Кнопки: "Добавить", "Отказаться"

**GET:/Update?id=X**
- Форма для изменения контакта
- Список контактов заблокирован
- Поля заполнены данными выбранного контакта
- Кнопки: "Изменить", "Удалить", "Отказаться"
- При вводе текста кнопка "Удалить" блокируется (JS)

**POST:/Add**
- Добавляет новый контакт в phonebook.json
- Редирект на GET:/

**POST:/Update**
- Обновляет контакт в phonebook.json
- Редирект на GET:/

**POST:/Delete**
- Удаляет контакт из phonebook.json
- Редирект на GET:/

### 2. Handlebars компоненты

**Layout (main.handlebars)**
- Общий HTML-шаблон для всех страниц
- Содержит CSS стили
- Содержит JavaScript для блокировки кнопки "Удалить"

**Partial (contactList.handlebars)**
- Переиспользуемый компонент списка контактов
- На главной странице - активные ссылки
- На других страницах - заблокированные кнопки

**Helper (cancelButton)**
- Функция в server.js для генерации кнопки "Отказаться"
- Использование: `{{{cancelButton "/"}}}`

### 3. Работа с данными

**phonebook.json** - структура:
```json
[
  {
    "id": 1,
    "name": "Имя",
    "phone": "+375291234567"
  }
]
```

**Функции:**
- `readPhonebook()` - читает JSON файл
- `writePhonebook(data)` - записывает в JSON файл

### 4. JavaScript функционал

В `main.handlebars` есть скрипт:
```javascript
// Находит поле ввода и кнопку удаления
const updateInput = document.getElementById('updateInput');
const deleteBtn = document.getElementById('deleteBtn');

// При изменении текста блокирует кнопку "Удалить"
updateInput.addEventListener('input', function() {
    if (this.value.trim() !== this.defaultValue.trim()) {
        deleteBtn.disabled = true;
    } else {
        deleteBtn.disabled = false;
    }
});
```

### 5. CSS стили

Все стили встроены в `main.handlebars`:
- Градиентный фон
- Белая карточка с тенью
- Анимации при наведении
- Адаптивный дизайн

## Тестирование

1. Откройте http://localhost:3000
2. Проверьте добавление контакта
3. Проверьте изменение контакта
4. Проверьте удаление контакта
5. Проверьте блокировку кнопки "Удалить" при вводе текста

## Деплой на Heroku

1. Создайте файл `Procfile`:
```
web: node server.js
```

2. Инициализируйте git:
```bash
git init
git add .
git commit -m "Initial commit"
```

3. Создайте приложение на Heroku:
```bash
heroku create your-phonebook-app
git push heroku master
```

4. Откройте приложение:
```bash
heroku open
```

## Технологии

- **Express** - веб-фреймворк
- **Express-Handlebars** - шаблонизатор
- **Node.js** - серверная платформа
- **JSON** - хранение данных
