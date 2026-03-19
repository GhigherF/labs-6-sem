# ПОДРОБНОЕ ОБЪЯСНЕНИЕ РАБОТЫ ПРИЛОЖЕНИЯ

## 📁 Структура проекта

```
4/
├── server.js                    # Главный сервер Express
├── package.json                 # Зависимости проекта
├── phonebook.json              # База данных (JSON файл)
├── demo.html                   # Демо-версия (одностраничное приложение)
├── Procfile                    # Конфигурация для Heroku
├── views/
│   ├── layouts/
│   │   └── main.handlebars     # Общий макет (layout)
│   ├── partials/
│   │   └── contactList.handlebars  # Переиспользуемый компонент
│   ├── index.handlebars        # Главная страница
│   ├── add.handlebars          # Страница добавления
│   └── update.handlebars       # Страница изменения
└── public/                     # Статические файлы (CSS, JS, изображения)
```

---

## 🚀 ЗАПУСК ПРИЛОЖЕНИЯ

### 1. Установка зависимостей
```bash
cd c:\labs\labs-6-sem\PSKP\4
npm install
```

### 2. Запуск сервера
```bash
npm start
```

### 3. Открыть в браузере
```
http://localhost:3000
```

### 4. Демо-версия (без сервера)
Просто откройте файл `demo.html` в браузере

---

## 🔧 КАК РАБОТАЕТ КАЖДЫЙ КОМПОНЕНТ

### 1️⃣ server.js - Главный файл сервера

```javascript
const express = require('express');
const { engine } = require('express-handlebars');
```
**Что делает:** Импортирует Express и Handlebars

```javascript
app.engine('handlebars', engine({
    defaultLayout: 'main',
    helpers: {
        cancelButton: function(url) {
            return `<a href="${url}" class="btn btn-cancel">Отказаться</a>`;
        }
    }
}));
```
**Что делает:** 
- Настраивает Handlebars как шаблонизатор
- Устанавливает `main.handlebars` как общий макет
- Создает helper `cancelButton` для кнопки "Отказаться"

```javascript
app.use(express.static('public'));
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
```
**Что делает:**
- `express.static('public')` - раздает статические файлы из папки public
- `express.urlencoded()` - парсит данные форм (POST запросы)
- `express.json()` - парсит JSON данные

```javascript
function readPhonebook() {
    const data = fs.readFileSync(PHONEBOOK_FILE, 'utf8');
    return JSON.parse(data);
}
```
**Что делает:** Читает JSON файл и преобразует в JavaScript объект

```javascript
app.get('/', (req, res) => {
    const phonebook = readPhonebook();
    res.render('index', { 
        contacts: phonebook,
        isMainPage: true
    });
});
```
**Что делает:**
- Обрабатывает GET запрос на главную страницу
- Читает контакты из JSON
- Рендерит шаблон `index.handlebars` с данными

```javascript
app.post('/Add', (req, res) => {
    const phonebook = readPhonebook();
    const newContact = {
        id: phonebook.length > 0 ? Math.max(...phonebook.map(c => c.id)) + 1 : 1,
        name: req.body.name,
        phone: req.body.phone
    };
    phonebook.push(newContact);
    writePhonebook(phonebook);
    res.redirect('/');
});
```
**Что делает:**
- Обрабатывает POST запрос для добавления контакта
- Генерирует новый ID (максимальный + 1)
- Добавляет контакт в массив
- Сохраняет в JSON файл
- Перенаправляет на главную страницу

---

### 2️⃣ main.handlebars - Общий макет

```html
<!DOCTYPE html>
<html>
<head>
    <style>
        /* CSS стили */
    </style>
</head>
<body>
    <div class="container">
        {{{body}}}  <!-- Сюда вставляется содержимое страниц -->
    </div>
    
    <script>
        /* JavaScript код */
    </script>
</body>
</html>
```

**Что делает:**
- `{{{body}}}` - место, куда вставляется содержимое других шаблонов
- Содержит общие стили для всех страниц
- Содержит JavaScript для блокировки кнопки "Удалить"

**JavaScript в макете:**
```javascript
const updateInput = document.getElementById('updateInput');
const deleteBtn = document.getElementById('deleteBtn');

if (updateInput && deleteBtn) {
    updateInput.addEventListener('input', function() {
        if (this.value.trim() !== this.defaultValue.trim()) {
            deleteBtn.disabled = true;  // Блокирует кнопку
        } else {
            deleteBtn.disabled = false; // Разблокирует
        }
    });
}
```
**Что делает:** При изменении текста в поле ввода блокирует кнопку "Удалить"

---

### 3️⃣ contactList.handlebars - Partial (переиспользуемый компонент)

```handlebars
{{#each contacts}}
    {{#if ../isMainPage}}
        <a href="/Update?id={{this.id}}" class="contact-btn">
            {{this.name}} - {{this.phone}}
        </a>
    {{else}}
        <button class="contact-btn" disabled>
            {{this.name}} - {{this.phone}}
        </button>
    {{/if}}
{{/each}}
```

**Что делает:**
- `{{#each contacts}}` - цикл по всем контактам
- `{{#if ../isMainPage}}` - проверяет, главная ли это страница
- Если главная - создает активные ссылки
- Если нет - создает заблокированные кнопки
- `{{this.name}}` - выводит имя контакта
- `{{this.phone}}` - выводит телефон

**Использование в других шаблонах:**
```handlebars
{{> contactList}}
```

---

### 4️⃣ index.handlebars - Главная страница

```handlebars
<h1>Телефонный справочник</h1>

<div class="contacts-list">
    {{> contactList}}  <!-- Вставляет partial -->
</div>

<div class="add-btn-container">
    <a href="/Add" class="btn btn-primary">Добавить</a>
</div>
```

**Что делает:**
- Отображает заголовок
- Вставляет список контактов через partial
- Показывает кнопку "Добавить"

---

### 5️⃣ add.handlebars - Страница добавления

```handlebars
<form method="POST" action="/Add">
    <div class="form-group">
        <input type="text" name="name" placeholder="Имя" required>
    </div>
    <div class="form-group">
        <input type="tel" name="phone" placeholder="Телефон" required>
    </div>
    <div class="actions">
        <button type="submit" class="btn btn-primary">Добавить</button>
        {{{cancelButton "/"}}}  <!-- Использует helper -->
    </div>
</form>
```

**Что делает:**
- `method="POST"` - отправляет POST запрос
- `action="/Add"` - на маршрут /Add
- `name="name"` - имя поля (доступно в req.body.name)
- `{{{cancelButton "/"}}}` - вызывает helper для кнопки "Отказаться"

---

### 6️⃣ update.handlebars - Страница изменения

```handlebars
<form method="POST" action="/Update">
    <input type="hidden" name="id" value="{{selectedContact.id}}">
    <div class="form-group">
        <input type="text" 
               id="updateInput" 
               name="name" 
               value="{{selectedContact.name}}" 
               placeholder="Имя" 
               required>
    </div>
    <!-- ... -->
</form>

<form method="POST" action="/Delete">
    <input type="hidden" name="id" value="{{selectedContact.id}}">
    <button type="submit" id="deleteBtn" class="btn btn-danger">Удалить</button>
</form>
```

**Что делает:**
- Две отдельные формы: для изменения и удаления
- `type="hidden"` - скрытое поле с ID контакта
- `value="{{selectedContact.name}}"` - заполняет поле данными
- `id="updateInput"` - для JavaScript блокировки кнопки

---

## 🎯 ПОТОК ДАННЫХ

### Добавление контакта:
```
1. Пользователь на GET:/ нажимает "Добавить"
   ↓
2. Браузер переходит на GET:/Add
   ↓
3. Сервер рендерит add.handlebars
   ↓
4. Пользователь заполняет форму и нажимает "Добавить"
   ↓
5. Браузер отправляет POST:/Add с данными формы
   ↓
6. Сервер добавляет контакт в phonebook.json
   ↓
7. Сервер делает redirect на GET:/
   ↓
8. Браузер показывает обновленный список
```

### Изменение контакта:
```
1. Пользователь на GET:/ нажимает на контакт
   ↓
2. Браузер переходит на GET:/Update?id=1
   ↓
3. Сервер находит контакт по ID и рендерит update.handlebars
   ↓
4. Пользователь изменяет данные и нажимает "Изменить"
   ↓
5. Браузер отправляет POST:/Update с новыми данными
   ↓
6. Сервер обновляет контакт в phonebook.json
   ↓
7. Redirect на GET:/
```

### Удаление контакта:
```
1. На странице GET:/Update пользователь нажимает "Удалить"
   ↓
2. Браузер отправляет POST:/Delete с ID контакта
   ↓
3. Сервер удаляет контакт из phonebook.json
   ↓
4. Redirect на GET:/
```

---

## 🎨 CSS СТИЛИ

### Градиентный фон:
```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```
Создает красивый фиолетовый градиент

### Анимация кнопок:
```css
.contact-btn:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}
```
При наведении кнопка поднимается и появляется тень

### Блокировка кнопок:
```css
.contact-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}
```
Заблокированные кнопки полупрозрачные

---

## 📊 СТРУКТУРА JSON

```json
[
  {
    "id": 1,
    "name": "Иван Иванов",
    "phone": "+375291234567"
  }
]
```

- `id` - уникальный идентификатор
- `name` - имя контакта
- `phone` - номер телефона

---

## 🌐 ДЕПЛОЙ НА HEROKU

### 1. Установить Heroku CLI
```bash
npm install -g heroku
```

### 2. Войти в аккаунт
```bash
heroku login
```

### 3. Инициализировать Git
```bash
git init
git add .
git commit -m "Initial commit"
```

### 4. Создать приложение
```bash
heroku create my-phonebook-app
```

### 5. Задеплоить
```bash
git push heroku master
```

### 6. Открыть приложение
```bash
heroku open
```

---

## 🧪 ТЕСТИРОВАНИЕ

### Тест 1: Добавление контакта
1. Откройте http://localhost:3000
2. Нажмите "Добавить"
3. Введите имя и телефон
4. Нажмите "Добавить"
5. Проверьте, что контакт появился в списке

### Тест 2: Изменение контакта
1. Нажмите на любой контакт
2. Измените имя или телефон
3. Нажмите "Изменить"
4. Проверьте, что данные обновились

### Тест 3: Блокировка кнопки "Удалить"
1. Нажмите на контакт
2. Начните вводить текст в поле "Имя"
3. Проверьте, что кнопка "Удалить" заблокировалась
4. Верните исходное значение
5. Проверьте, что кнопка разблокировалась

### Тест 4: Удаление контакта
1. Нажмите на контакт
2. Нажмите "Удалить"
3. Проверьте, что контакт исчез из списка

### Тест 5: Отказ от действия
1. Нажмите "Добавить"
2. Нажмите "Отказаться"
3. Проверьте, что вернулись на главную страницу

---

## 💡 КЛЮЧЕВЫЕ КОНЦЕПЦИИ

### 1. MVC паттерн
- **Model** - phonebook.json (данные)
- **View** - Handlebars шаблоны (отображение)
- **Controller** - Express маршруты (логика)

### 2. Handlebars компоненты
- **Layout** - общий макет для всех страниц
- **Partial** - переиспользуемые компоненты
- **Helper** - функции для генерации HTML

### 3. REST API принципы
- GET - получение данных
- POST - создание/изменение/удаление данных
- Redirect после POST (Post-Redirect-Get паттерн)

### 4. Разделение ответственности
- server.js - только маршруты и логика
- views/ - только отображение
- public/ - только статические файлы

---

## 🔍 ЧАСТЫЕ ВОПРОСЫ

**Q: Почему используется redirect после POST?**
A: Чтобы избежать повторной отправки формы при обновлении страницы (F5)

**Q: Зачем нужен Layout?**
A: Чтобы не дублировать HTML, CSS и JS на каждой странице

**Q: Почему Partial для списка контактов?**
A: Список используется на всех трех страницах, Partial избегает дублирования кода

**Q: Как работает Helper?**
A: Helper - это функция, которая генерирует HTML. Вызывается как `{{{helperName param}}}`

**Q: Почему три фигурные скобки {{{ }}}?**
A: Две скобки {{ }} экранируют HTML, три {{{ }}} - нет. Для HTML нужны три скобки

---

## 📝 ИТОГИ

✅ Приложение использует Express
✅ Использует Express-Handlebars
✅ Все формы через Handlebars шаблоны
✅ Общий макет (Layout)
✅ Переиспользуемый компонент (Partial)
✅ Helper для кнопки "Отказаться"
✅ Статические файлы через Express
✅ Данные в JSON файле
✅ Готово к деплою на Heroku
✅ Минимальный дизайн с CSS
✅ JavaScript для блокировки кнопки
✅ Демо-версия в одном HTML файле
