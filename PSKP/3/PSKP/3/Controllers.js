let model = require("./Model")
exports.test_get = (req, res) => {
    if (!model.test_json ) res.status(404).send("JSON не найден")
   return res.json(model.test_json);
};

exports.test_post = (req, res) => {
    let n1 = req.params.n1;
    let n2 = req.params.n2;
    
    if (isNaN(n1) || isNaN(n2)) {
        return res.status(400).send("Параметры n1 и n2 должны быть числами");
    }else{
    model.test_json = { n1, n2};
    return res.json(model.test_json);
}};

exports.test_put = (req, res) => {
    let n1 = req.params.n1;
    let n2 = req.params.n2;
    
    if (isNaN(n1) || isNaN(n2)) {
        return res.status(400).send("Параметры n1 и n2 должны быть числами");
    }else{
    model.test_json = { n1, n2};
    return res.json(model.test_json);
}};

exports.test_delete = (req, res) => {
        model.test_json = undefined;
        return res.status(200).send("Успешно удалено");}