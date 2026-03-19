const express= require("express")
const app = express();

app.use(express.json());

const myrouter = new(require("./Model").MVCRouter)(
    `/:controller/:n1/:n2`
);

const handlers = require("./Controllers")
const controllers = new (require("./Model")).MVControllers(
    {
    test:
    {
        get: handlers.test_get,
        post: handlers.test_post,
        put: handlers.test_put,
        delete: handlers.test_delete
    }}
)

const mvc = new(require("./Model")).MVC(myrouter, controllers);

myrouter.uri_templates.forEach(route => {
    app.all(route, mvc.use);
});

app.listen(3000, () => {
    console.log('Сервер запущен на порту 3000');
});