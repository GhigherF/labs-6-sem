let test_json;

function MVCRouter(uri_templates)
{
    this.uri_templates = [...arguments]
}

function MVControllers(controller_map)
{
    this.controller_map = controller_map;
}

function MVC(router,controllers)
{
    this.router=router;
    this.controllers = controllers;
    this.use = (req,res,next)=>{
        let c = this.controllers.controller_map[req.params.controller];
        if (c)
        {
            let method = req.method.toLowerCase();
            let handler = c[method];
            if (handler) {
                handler(req, res, next);
            } else {
                res.status(405).send(`Метод ${req.method} не поддерживается`);
            }
        }
        else next();
    }
}



exports.MVCRouter = MVCRouter;
exports.MVControllers = MVControllers;
exports.MVC = MVC;
exports.test_json = test_json;