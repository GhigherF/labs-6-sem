const express = require("express");
const app = express();
const passport = require("passport");
const BasicStrategy = require('passport-http').BasicStrategy;
const credentials = require('./cred.json');
const session = require("express-session")({
    resave: false,
    saveUninitialized: false,
    secret: "secret"
});

passport.use(new BasicStrategy((user, password, done) => {
    const cr = credentials.find(e => e.user.toUpperCase() === user.toUpperCase());
    if (!cr) return done(null, false, { message: 'incorrect username' });
    if (cr.password !== password) return done(null, false, { message: 'incorrect password' });
    return done(null, user);
}));

passport.serializeUser((user, done) => done(null, user));
passport.deserializeUser((user, done) => done(null, user));

app.use(session);
app.use(passport.initialize());
app.use(passport.session());

app.get('/login', (req, res, next) => {
    if (req.session.logout && req.headers['authorization']) {
        req.session.logout = false;
        delete req.headers['authorization'];
    }
    next();
}, passport.authenticate('basic'), (req, res) => {
    res.redirect('/resource');
});

app.get('/logout', (req, res) => {
    req.session.destroy(() => {
        res.set('WWW-Authenticate', 'Basic realm="Users"');
        res.status(401).send('Logged out');
    });
});

app.get('/resource', (req, res) => {
    if (!req.isAuthenticated() || req.session.logout) return res.redirect('/login');
    res.send('RESOURCE');
});

app.use((req, res) => {
    res.status(404).send('404 Not Found');
});

app.listen(3000);
