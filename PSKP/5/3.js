const express = require("express");
const app = express();
const session = require("express-session");
const credentials = require("./cred.json");

app.use(session({
    secret: "secret",
    resave: false,
    saveUninitialized: false
}));

app.use(express.urlencoded({ extended: true }));


function authMiddleware(req, res, next) {
    if (req.session.user) {
        return next();
    }
    res.redirect("/login");
}

app.get("/login", (req, res) => {
    if (req.session.user) {
        return res.redirect("/resource");
    }
    res.send(`
        <h1>Login</h1>
        <form method="POST" action="/login" >
            <input name="user" style = "margin:5" placeholder="Username" /><br/>
            <input name="password" style = "margin:5" type="password" placeholder="Password" /><br/>
            <button type="submit">Login</button>
        </form>
    `);
});
app.post("/login", (req, res) => {
    const { user, password } = req.body;

    if (!user || !password) {
        return res.status(400).send("Missing credentials");
    }

    const found = credentials.find(
        e => e.user.toUpperCase() === user.toUpperCase()
    );

    if (!found || found.password !== password) {
        return res.status(401).send("Invalid credentials");
    }

    req.session.user = found.user;

    res.redirect("/resource");
});


app.get("/resource", authMiddleware, (req, res) => {
    res.send(`RESOURCE`);
});

app.get("/logout", (req, res) => {
    req.session.destroy(() => {
        res.redirect("/login");
    });
});

app.use((req, res) => {
    res.status(404).send("404 Not Found");
});

app.listen(3000);